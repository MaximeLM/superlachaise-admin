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

    redirects = get_redirects(commons_categories_to_refresh)
    while len(redirects) > 0:
        logger.info("Found {} redirect Commons categories to refresh".format(len(redirects)))
        orphaned_objects = [commons_category for commons_category in orphaned_objects if commons_category not in redirects]
        request_commons_categories(redirects)
        redirects = get_redirects(redirects)

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

def get_redirects(commons_categories):
    redirects = []

    for commons_category in commons_categories:
        if commons_category.redirect and not commons_category.redirect in redirects:
            redirects.append(commons_category.redirect)

    return redirects

# Request Commons

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
    logger.info("Request {}".format(COMMONS_API_BASE_URL))
    entry_count = 0
    entry_total = len(commons_categories)
    for commons_categories_chunk in sync_utils.make_chunks(list(commons_categories)):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(commons_categories_chunk)

        # Prepare commons categories
        for commons_category in commons_categories_chunk:
            commons_category.default_sort = None
            commons_category.image = None
            commons_category.redirect = None

        commons_query_params = make_commons_query_params(commons_categories_chunk)
        last_continue = {'continue': ''}
        while last_continue:
            logger.debug("last_continue: {}".format(last_continue))
            commons_query_params.update(last_continue)
            result = request_commons_api(commons_query_params)
            last_continue = handle_commons_api_result(result, commons_categories_chunk)

        # Check and save commons categories
        for commons_category in commons_categories_chunk:
            if not commons_category.default_sort:
                logger.warning("Default sort is missing for Commons category \"{}\"".format(commons_category.id))
                commons_category.default_sort = ''
            if not commons_category.image:
                logger.warning("Image is missing for Commons category \"{}\"".format(commons_category.id))
                commons_category.image = ''
            if commons_category.redirect:
                logger.warning("Commons category \"{}\" is a redirect for \"{}\"".format(commons_category.id, commons_category.redirect.id))
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
            commons_category.default_sort = get_default_sort(wikitext)
            commons_category.image = get_image(wikitext)
            redirect_id = get_redirect_id(wikitext)
            if redirect_id:
                redirect, was_created = CommonsCategory.objects.get_or_create(id=redirect_id)
                if was_created:
                    logger.debug("Created redirect CommonsCategory "+redirect.id)
                else:
                    logger.debug("Matched redirect CommonsCategory "+redirect.id)
                commons_category.redirect = redirect
    if len(commons_categories_by_title) > 0:
        raise CommonsAPIMissingPagesError(commons_categories_by_title.values())
    if 'continue' in result:
        return result['continue']

DEFAULT_SORT_PATTERN = re.compile("^{{DEFAULTSORT:[\s]*(.*)[\s]*}}$")
def get_default_sort(wikitext):
    for line in wikitext.split('\n'):
        match = DEFAULT_SORT_PATTERN.match(line)
        if match:
            return match.group(1)

IMAGE_PATTERN = re.compile("^[\s]*\|image[\s]*=[\s]*(.*)[\s]*$")
def get_image(wikitext):
    for line in wikitext.split('\n'):
        match = IMAGE_PATTERN.match(line)
        if match:
            return match.group(1)

REDIRECT_PATTERN = re.compile("^{{Category redirect\|[\s]*Category:(.*)[\s]*}}$")
def get_redirect_id(wikitext):
    for line in wikitext.split('\n'):
        match = REDIRECT_PATTERN.match(line)
        if match:
            return match.group(1)
