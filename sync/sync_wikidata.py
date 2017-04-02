import logging
import os
import importlib.machinery
import json
from django.conf import settings
from requests.exceptions import RequestException
from json.decoder import JSONDecodeError

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync wikidata ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    wikidata_entries_to_refresh, created = get_or_create_wikidata_entries_to_refresh(ids)

    logger.info('Request Wikidata API')
    for wikidata_entries in make_chunks(wikidata_entries_to_refresh):
        entities = request_wikidata_entities(make_wikidata_query_params(wikidata_entries))

    logger.info("Created {} entries".format(created))

    logger.info('== end sync wikidata ==')

def delete_objects():
    WikidataEntry.objects.all().delete()

# Prepare model

def get_first_matching_wikidata_id(openstreetmap_element, openstreetmap_id_tags):
    tags = openstreetmap_element.tags()
    if tags:
        for openstreetmap_id_tag in openstreetmap_id_tags:
            if openstreetmap_id_tag in tags:
                return tags[openstreetmap_id_tag]
    else:
        logger.error("Invalid tags for OpenStreetMap element {} - {}".format(openstreetmap_element.id, openstreetmap_element.name))

def get_or_create_wikidata_entries_from_openstreetmap_elements(openstreetmap_elements, openstreetmap_id_tags):
    wikidata_entries = []
    created = 0

    for openstreetmap_element in openstreetmap_elements:
        wikidata_id = get_first_matching_wikidata_id(openstreetmap_element, openstreetmap_id_tags)
        if wikidata_id:
            wikidata_entry, was_created = WikidataEntry.objects.get_or_create(id=wikidata_id)
            wikidata_entries.append(wikidata_entry)
            if was_created:
                logger.debug("Created WikidataEntry "+wikidata_entry.id)
                created = created + 1
            else:
                logger.debug("Matched WikidataEntry "+wikidata_entry.id)
            openstreetmap_element.wikidata_entry = wikidata_entry
        else:
            logger.warning("No Wikidata ID found for OpenStreetMap element {} - {}".format(openstreetmap_element.id, openstreetmap_element.name))
            openstreetmap_element.wikidata_entry = None
        openstreetmap_element.save()

    return (wikidata_entries, created)

def get_or_create_wikidata_entries_to_refresh(ids, openstreetmap_id_tags=config.wikidata.OPENSTREETMAP_ID_TAGS):
    if ids:
        return (list(WikidataEntry.objects.filter(id__in=ids)), 0)
    else:
        logger.info('List Wikidata entries from OpenStreetMap elements')
        return get_or_create_wikidata_entries_from_openstreetmap_elements(list(OpenStreetMapElement.objects.all()), openstreetmap_id_tags)

# Request Wikidata

def make_chunks(wikidata_entries, chunk_size=50):
    """ Cut the list in chunks of a specified size """
    return [wikidata_entries[i:i+chunk_size] for i in range(0, len(wikidata_entries), chunk_size)]

def make_wikidata_query_params(wikidata_entries, languages=config.wikidata.LANGUAGES):
    return {
        'action': 'wbgetentities',
        'ids': '|'.join([wikidata_entry.id for wikidata_entry in wikidata_entries]),
        'props': '|'.join(['labels', 'descriptions', 'claims', 'sitelinks']),
        'languages': '|'.join(languages),
        'format': 'json',
    }

WIKIDATA_API_BASE_URL = "https://www.wikidata.org/w/api.php"
def request_wikidata_entities(wikidata_query_params):
    logger.debug("Wikidata query params:")
    logger.debug(wikidata_query_params)

    # Request data
    result = sync_utils.request(WIKIDATA_API_BASE_URL, params=wikidata_query_params)

    # Return JSON
    return result.json()
