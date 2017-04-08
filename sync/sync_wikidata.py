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

    orphaned_wikidata_entries = get_local_wikidata_entries(ids)

    wikidata_entries_to_refresh, created = get_or_create_wikidata_entries_to_refresh(ids)
    logger.info("Found {} Wikidata entries to refresh (created {})".format(len(wikidata_entries_to_refresh), created))

    logger.info('Request Wikidata API')
    request_wikidata_entries(wikidata_entries_to_refresh, orphaned_wikidata_entries)

    for wikidata_entry in orphaned_wikidata_entries:
        logger.debug("Deleted WikidataEntry "+wikidata_entry.id)
        wikidata_entry.delete()
    logger.info("Deleted {} elements".format(len(orphaned_wikidata_entries)))

    logger.info('== end sync wikidata ==')

def delete_objects():
    WikidataEntry.objects.all().delete()

def get_local_wikidata_entries(ids):
    if ids:
        return list(WikidataEntry.objects.filter(id__in=ids))
    else:
        return list(WikidataEntry.objects.all())

# Prepare model

def get_or_create_wikidata_entries_from_openstreetmap_elements(openstreetmap_elements, openstreetmap_id_tags):
    wikidata_entries = []
    created = 0

    for openstreetmap_element in openstreetmap_elements:
        wikidata_id = openstreetmap_element.get_first_tag_value(openstreetmap_id_tags)
        if wikidata_id:
            wikidata_entry, was_created = WikidataEntry.objects.get_or_create(id=wikidata_id)
            if not wikidata_entry in wikidata_entries:
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
def request_wikidata_api(wikidata_query_params):
    logger.debug("Wikidata query params:")
    logger.debug(wikidata_query_params)

    # Request data
    result = sync_utils.request(WIKIDATA_API_BASE_URL, params=wikidata_query_params)

    # Return JSON
    return result.json()

def request_wikidata_entries(wikidata_entries, orphaned_wikidata_entries):
    entry_count = 0
    for wikidata_entries_chunk in make_chunks(list(wikidata_entries)):
        logger.info(str(entry_count)+"/"+str(len(wikidata_entries)))
        entry_count = entry_count + len(wikidata_entries_chunk)

        retry = True
        while retry:
            retry = False
            result = request_wikidata_api(make_wikidata_query_params(wikidata_entries_chunk))
            try:
                handle_wikidata_api_result(result, wikidata_entries_chunk, orphaned_wikidata_entries)
            except WikidataNoSuchEntityError as error:
                if error.wikidata_entry in wikidata_entries_chunk:
                    wikidata_entries_chunk.remove(error.wikidata_entry)
                    retry = True

    logger.info(str(entry_count)+"/"+str(len(wikidata_entries)))

class WikidataError(Exception):
    pass

class WikidataNoSuchEntityError(WikidataError):
    def __init__(self, message, wikidata_entry):
        super(WikidataNoSuchEntityError, self).__init__(message)
        self.wikidata_entry = wikidata_entry

def handle_wikidata_api_result(result, wikidata_entries, orphaned_wikidata_entries):
    if 'error' in result:
        if result['error']['code'] == 'no-such-entity':
            wikidata_id = result['error']['id']
            for wikidata_entry in wikidata_entries:
                if wikidata_entry.id == wikidata_id:
                    logger.warning("No such entity for Wikidata ID {}".format(wikidata_id))
                    raise WikidataNoSuchEntityError(result['error']['info'], wikidata_entry)
        raise WikidataError(result['error']['info'])
    for wikidata_entry in wikidata_entries:
        entity = result['entities'][wikidata_entry.id]
        labels = entity['labels']
        if len(labels) > 0:
            # Get any label from the list
            wikidata_entry.name = next(iter(labels.values()))['value']
        else:
            logger.warning("Name is missing for Wikidata ID {}".format(id))
            wikidata_entry.name = ""
        wikidata_entry.raw_labels = json.dumps(entity['labels'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.raw_descriptions = json.dumps(entity['descriptions'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.raw_claims = json.dumps(entity['claims'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.raw_sitelinks = json.dumps(entity['sitelinks'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.save()
        if wikidata_entry in orphaned_wikidata_entries:
            orphaned_wikidata_entries.remove(wikidata_entry)
