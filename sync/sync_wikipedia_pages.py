import logging
import os
import importlib.machinery
import json
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync wikipedia pages ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_wikipedia_pages = [] if ids else list(WikipediaPage.objects.all())

    wikipedia_pages_to_refresh, created = get_or_create_wikipedia_pages_to_refresh(ids)
    logger.info("Found {} Wikipedia pages to refresh (created {})".format(sum(len(wikipedia_pages) for wikipedia_pages in wikipedia_pages_to_refresh.values()), created))

    for (language, wikipedia_pages) in wikipedia_pages_to_refresh.items():
        orphaned_wikipedia_pages = [wikipedia_page for wikipedia_page in orphaned_wikipedia_pages if wikipedia_page not in wikipedia_pages]

    request_wikipedia_pages(wikipedia_pages_to_refresh)

    for wikipedia_page in orphaned_wikipedia_pages:
        logger.debug("Deleted WikipediaPage "+wikipedia_page.id)
        wikipedia_page.delete()
    logger.info("Deleted {} orphaned elements".format(len(orphaned_wikipedia_pages)))

    logger.info('== end sync wikipedia pages ==')

def delete_objects():
    WikipediaPage.objects.all().delete()

# Prepare model

def get_or_create_wikipedia_pages_from_wikidata_entries(wikidata_entries, languages):
    wikipedia_pages = {language:[] for language in languages}
    created = 0

    for wikidata_entry in wikidata_entries:
        wikipedia_pages_for_wikidata_entry = []
        for language in languages:
            title = wikidata_entry.get_sitelink("{}wiki".format(language))
            if title:
                wikipedia_id = "{}|{}".format(language, title)
                wikipedia_page, was_created = WikipediaPage.objects.get_or_create(id=wikipedia_id)
                if not wikipedia_page in wikipedia_pages_for_wikidata_entry:
                    wikipedia_pages_for_wikidata_entry.append(wikipedia_page)
                if was_created:
                    logger.debug("Created WikipediaPage "+wikipedia_id)
                    created = created + 1
                else:
                    logger.debug("Matched WikipediaPage "+wikipedia_id)
                if not wikipedia_page in wikipedia_pages[language]:
                    wikipedia_pages[language].append(wikipedia_page)
            else:
                logger.warning("Wikipedia page for language '{}' is missing for wikidata entry {}".format(language, str(wikidata_entry)))
        wikidata_entry.wikipedia_pages.set(wikipedia_pages_for_wikidata_entry)

    return (wikipedia_pages, created)

def get_or_create_wikipedia_pages_to_refresh(ids, languages=config.wikidata.LANGUAGES):
    if ids:
        wikipedia_pages = {language:[] for language in languages}
        for wikipedia_page in WikipediaPage.objects.filter(id__in=ids):
            (language, title) = wikipedia_page.id_parts()
            if wikipedia_page not in wikipedia_pages[language]:
                wikipedia_pages[language].append(wikipedia_page)
        return (wikipedia_pages, 0)
    else:
        logger.info('List Wikipedia pages from Wikidata entries')
        return get_or_create_wikipedia_pages_from_wikidata_entries(list(WikidataEntry.objects.all()), languages)

# Request Wikipedia API

def make_chunks(wikipedia_pages, chunk_size=50):
    """ Cut the list in chunks of a specified size """
    return [wikipedia_pages[i:i+chunk_size] for i in range(0, len(wikipedia_pages), chunk_size)]

def make_wikipedia_query_params(wikipedia_pages):
    return {
        'action': 'query',
        'prop': 'revisions',
        'rvprop': 'content',
        'format': 'json',
        'titles': '|'.join([wikipedia_page.id_parts()[1] for wikipedia_page in wikipedia_pages]),
    }

class WikipediaAPIError(Exception):
    pass

WIKIPEDIA_API_BASE_URL = "https://{language}.wikipedia.org/w/api.php"
def request_wikipedia_api(wikipedia_query_params, language):
    logger.debug("wikipedia_query_params:")
    logger.debug(wikipedia_query_params)

    # Request data
    result = sync_utils.request(WIKIPEDIA_API_BASE_URL.format(language=language), params=wikipedia_query_params)

    # Return JSON
    return result.json()

def request_wikipedia_pages(wikipedia_pages):
    for (language, wikipedia_pages_for_language) in wikipedia_pages.items():
        logger.info("Request '{}' Wikipedia API".format(language))
        entry_count = 0
        entry_total = len(wikipedia_pages_for_language)
        for wikipedia_pages_chunk in make_chunks(list(wikipedia_pages_for_language)):
            logger.info(str(entry_count)+"/"+str(entry_total))
            entry_count = entry_count + len(wikipedia_pages_chunk)
            result = request_wikipedia_api(make_wikipedia_query_params(wikipedia_pages_chunk), language)
        logger.info(str(entry_count)+"/"+str(entry_total))
