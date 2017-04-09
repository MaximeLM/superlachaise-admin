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
    logger.info("Found {} Wikipedia pages to refresh (created {})".format(len(wikipedia_pages_to_refresh), created))

    orphaned_wikipedia_pages = [wikipedia_page for wikipedia_page in orphaned_wikipedia_pages if wikipedia_page not in wikipedia_pages_to_refresh]

    for wikipedia_page in orphaned_wikipedia_pages:
        logger.debug("Deleted WikipediaPage "+wikipedia_page.id)
        wikipedia_page.delete()
    logger.info("Deleted {} orphaned elements".format(len(orphaned_wikipedia_pages)))

    logger.info('== end sync wikipedia pages ==')

def delete_objects():
    WikipediaPage.objects.all().delete()

# Prepare model

def get_or_create_wikipedia_pages_from_wikidata_entries(wikidata_entries, languages):
    wikipedia_pages = []
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
            else:
                logger.warning("Wikipedia page for language '{}' is missing for wikidata entry {}".format(language, str(wikidata_entry)))
        wikidata_entry.wikipedia_pages.set(wikipedia_pages_for_wikidata_entry)
        wikipedia_pages.extend([wikipedia_page for wikipedia_page in wikipedia_pages_for_wikidata_entry if wikipedia_page not in wikipedia_pages])

    return (wikipedia_pages, created)

def get_or_create_wikipedia_pages_to_refresh(ids, languages=config.wikidata.LANGUAGES):
    if ids:
        return (list(WikipediaPage.objects.filter(id__in=ids)), 0)
    else:
        logger.info('List Wikipedia pages from Wikidata entries')
        return get_or_create_wikipedia_pages_from_wikidata_entries(list(WikidataEntry.objects.all()), languages)
