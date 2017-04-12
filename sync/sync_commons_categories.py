import logging
import os
import importlib.machinery
import json
import re
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync commons categories ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(CommonsCategory.objects.all())

    commons_categories_to_refresh, created = get_or_create_commons_categories_to_refresh(ids)
    logger.info("Found {} Commons categories to refresh (created {})".format(len(commons_categories_to_refresh), created))

    orphaned_objects = [commons_category for commons_category in orphaned_objects if commons_category not in commons_categories_to_refresh]

    request_commons_categories(commons_categories_to_refresh)

    for commons_category in orphaned_objects:
        logger.debug("Deleted CommonsCategory "+commons_category.id)
        commons_category.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync commons categories ==')

def delete_objects():
    CommonsCategory.objects.all().delete()

# Prepare model

def get_or_create_commons_categories_from_wikidata_entries(wikidata_entries, get_commons_category_id):
    created = 0
    commons_categories = []
    for wikidata_entry in wikidata_entries:
        commons_category_id = get_commons_category_id(wikidata_entry)
        if commons_category_id:
            commons_category, was_created = CommonsCategory.objects.get_or_create(id=commons_category_id)
            if was_created:
                logger.debug("Created CommonsCategory "+commons_category.id)
                created = created + 1
            else:
                logger.debug("Matched CommonsCategory "+commons_category.id)
            wikidata_entry.commons_category = commons_category
            if not commons_category in commons_categories:
                commons_categories.append(commons_category)
        else:
            logger.warning("No Commons category ID found for Wikidata entry {} - {}".format(wikidata_entry.id, wikidata_entry.name))
            wikidata_entry.commons_category = None
        wikidata_entry.save()
    return (commons_categories, created)

def get_or_create_commons_categories_to_refresh(ids, get_commons_category_id=config.commons.get_commons_category_id):
    if ids:
        return (list(CommonsCategory.objects.filter(id__in=ids)), 0)
    else:
        logger.info('List Commons categories from Wikidata entries')
        return get_or_create_commons_categories_from_wikidata_entries(list(WikidataEntry.objects.all()), get_commons_category_id)

# Request Commons

def make_chunks(commons_categories, chunk_size=50):
    """ Cut the list in chunks of a specified size """
    return [commons_categories[i:i+chunk_size] for i in range(0, len(commons_categories), chunk_size)]

def make_commons_query_params(commons_categories):
    return {
        'action': 'query',
        'prop': 'revisions',
        'rvprop': 'content',
        'format': 'json',
        'titles': '|'.join(["Category:"+commons_category.id for commons_category in commons_categories]),
    }

COMMONS_API_BASE_URL = "https://commons.wikimedia.org/w/api.php"
def request_commons_api(commons_query_params):
    logger.debug("commons_query_params:")
    logger.debug(commons_query_params)

    # Request data
    result = sync_utils.request(COMMONS_API_BASE_URL, params=commons_query_params)

    # Return JSON
    return result.json()

def request_commons_categories(commons_categories):
    logger.info("Request Commons API")
    entry_count = 0
    entry_total = len(commons_categories)
    for commons_categories_chunk in make_chunks(list(commons_categories)):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(commons_categories_chunk)

        # Prepare commons categories
        for commons_category in commons_categories_chunk:
            commons_category.wikitext = None

        commons_query_params = make_commons_query_params(commons_categories_chunk)
        last_continue = {'continue': ''}
        while last_continue:
            logger.debug("last_continue: {}".format(last_continue))
            commons_query_params.update(last_continue)
            result = request_commons_api(commons_query_params)
            last_continue = handle_commons_api_result(result, commons_categories_chunk)

        # Check and save commons categories
        for commons_category in commons_categories_chunk:
            if not commons_category.wikitext:
                logger.warning("Wikitext is missing for Commons category {}".format(commons_category.id))
                commons_category.wikitext = ''
            commons_category.save()
    logger.info(str(entry_count)+"/"+str(entry_total))

class CommonsAPIError(Exception):
    pass

class CommonsAPIMissingPagesError(CommonsAPIError):
    def __init__(self, commons_categories):
        super(CommonsAPIMissingPagesError, self).__init__("missing pages {}".format(str([commons_category.id for commons_category in commons_categories])))
        self.commons_categories = commons_categories

def handle_commons_api_result(result, commons_categories):
    if 'error' in result:
        raise CommonsAPIError(result['error']['info'])
    commons_categories_by_title = {"Category:"+commons_category.id:commons_category for commons_category in commons_categories}
    if 'normalized' in result['query']:
        for normalize in result['query']['normalized']:
            from_title = normalize['from']
            to_title = normalize['to']
            logger.warning("Commons category was normalized from {} to {}".format(from_title, to_title))
            commons_categories_by_title[to_title] = commons_categories_by_title.pop(from_title)
    for commons_category_dict in result['query']['pages'].values():
        commons_category = commons_categories_by_title.pop(commons_category_dict['title'])
        if 'missing' in commons_category_dict:
            raise CommonsAPIMissingPagesError([commons_category])
        if 'revisions' in commons_category_dict:
            wikitext = commons_category_dict['revisions'][0]['*']
            commons_category.wikitext = wikitext
    if len(commons_categories_by_title) > 0:
        raise CommonsAPIMissingPagesError(commons_categories_by_title.values())
    if 'continue' in result:
        return result['continue']
