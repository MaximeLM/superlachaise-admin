import logging, os, importlib.machinery, json
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync wikidata entries ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(WikidataEntry.objects.all())

    wikidata_entries_to_refresh, created = get_or_create_wikidata_entries_to_refresh(ids)
    logger.info("Found {} Wikidata entries to refresh (created {})".format(len(wikidata_entries_to_refresh), created))

    orphaned_objects = [wikidata_entry for wikidata_entry in orphaned_objects if wikidata_entry not in wikidata_entries_to_refresh]

    logger.info("Request {}".format(WIKIDATA_API_BASE_URL))
    request_wikidata_entries(wikidata_entries_to_refresh)

    secondary_wikidata_entries, created = get_or_create_secondary_wikidata_entries(wikidata_entries_to_refresh)
    logger.info("Found {} secondary Wikidata entries to refresh (created {})".format(len(secondary_wikidata_entries), created))

    logger.info('Request Wikidata API for secondary entries')
    request_wikidata_entries(secondary_wikidata_entries)

    orphaned_objects = [wikidata_entry for wikidata_entry in orphaned_objects if wikidata_entry not in secondary_wikidata_entries]

    for wikidata_entry in orphaned_objects:
        logger.debug("Deleted WikidataEntry "+wikidata_entry.id)
        wikidata_entry.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync wikidata entries ==')

def delete_objects():
    WikidataEntry.objects.all().delete()

# Prepare model

def get_or_create_wikidata_entries_from_openstreetmap_elements(openstreetmap_elements, get_wikidata_entry_id=config.openstreetmap.get_wikidata_entry_id):
    wikidata_entries = []
    created = 0

    for openstreetmap_element in openstreetmap_elements:
        wikidata_id = get_wikidata_entry_id(openstreetmap_element)
        if wikidata_id:
            wikidata_entry, was_created = WikidataEntry.objects.get_or_create(id=wikidata_id)
            if was_created:
                logger.debug("Created WikidataEntry "+wikidata_entry.id)
                created = created + 1
            else:
                logger.debug("Matched WikidataEntry "+wikidata_entry.id)
            openstreetmap_element.wikidata_entry = wikidata_entry
            if not wikidata_entry in wikidata_entries:
                wikidata_entries.append(wikidata_entry)
        else:
            logger.warning("No Wikidata ID found for Openstreetmap element {}".format(openstreetmap_element))
            openstreetmap_element.wikidata_entry = None
        openstreetmap_element.save()

    return (wikidata_entries, created)

def get_or_create_wikidata_entries_to_refresh(ids):
    if ids:
        return (list(WikidataEntry.objects.filter(id__in=ids)), 0)
    else:
        logger.info('List Wikidata entries from Openstreetmap elements')
        return get_or_create_wikidata_entries_from_openstreetmap_elements(list(OpenstreetmapElement.objects.all()))

def get_or_create_secondary_wikidata_entries(primary_wikidata_entries, get_secondary_wikidata_entries=config.wikidata.get_secondary_wikidata_entries):
    created = 0
    secondary_wikidata_entries = []
    for primary_wikidata_entry in primary_wikidata_entries:
        secondary_wikidata_entries_for_primary_wikidata_entry = []
        for wikidata_id in get_secondary_wikidata_entries(primary_wikidata_entry):
            secondary_wikidata_entry, was_created = WikidataEntry.objects.get_or_create(id=wikidata_id)
            if not secondary_wikidata_entry in secondary_wikidata_entries_for_primary_wikidata_entry:
                secondary_wikidata_entries_for_primary_wikidata_entry.append(secondary_wikidata_entry)
            if was_created:
                logger.debug("Created WikidataEntry "+secondary_wikidata_entry.id)
                created = created + 1
            else:
                logger.debug("Matched WikidataEntry "+secondary_wikidata_entry.id)
        primary_wikidata_entry.secondary_wikidata_entries.set(secondary_wikidata_entries_for_primary_wikidata_entry)
        secondary_wikidata_entries.extend([wikidata_entry for wikidata_entry in secondary_wikidata_entries_for_primary_wikidata_entry if wikidata_entry not in secondary_wikidata_entries])
    return (secondary_wikidata_entries, created)

# Request Wikidata

def make_wikidata_query_params(wikidata_entries, languages):
    return {
        'action': 'wbgetentities',
        'ids': '|'.join([wikidata_entry.id for wikidata_entry in wikidata_entries]),
        'props': '|'.join(['labels', 'descriptions', 'claims', 'sitelinks']),
        'languages': '|'.join(languages),
        'format': 'json',
    }

WIKIDATA_API_BASE_URL = "https://www.wikidata.org/w/api.php"
def request_wikidata_api(wikidata_query_params):
    result = sync_utils.request(WIKIDATA_API_BASE_URL, params=wikidata_query_params)
    return result.json()

def request_wikidata_entries(wikidata_entries, languages=config.base.LANGUAGES):
    entry_count = 0
    entry_total = len(wikidata_entries)
    no_such_entity_entry_count = 0
    for wikidata_entries_chunk in sync_utils.make_chunks(list(wikidata_entries)):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(wikidata_entries_chunk)

        retry = True
        while retry:
            retry = False
            result = request_wikidata_api(make_wikidata_query_params(wikidata_entries_chunk, languages))
            try:
                handle_wikidata_api_result(result, wikidata_entries_chunk, languages)
            except (WikidataAPINoSuchEntityError, WikidataAPIMissingEntityError) as error:
                no_such_entity_entry_count = no_such_entity_entry_count + 1
                if error.wikidata_entry in wikidata_entries_chunk:
                    wikidata_entries_chunk.remove(error.wikidata_entry)
                    wikidata_entries.remove(error.wikidata_entry)
                    retry = True

    logger.info(str(entry_count)+"/"+str(entry_total))
    if no_such_entity_entry_count > 0:
        logger.info("Deleted {} wikidata entries not found on Wikidata".format(no_such_entity_entry_count))

class WikidataAPIError(Exception):
    pass

class WikidataAPINoSuchEntityError(WikidataAPIError):
    def __init__(self, message, wikidata_entry):
        super(WikidataAPINoSuchEntityError, self).__init__(message)
        self.wikidata_entry = wikidata_entry

class WikidataAPIMissingEntityError(WikidataAPIError):
    def __init__(self, wikidata_id, wikidata_entry):
        super(WikidataAPIMissingEntityError, self).__init__("missing entity {}".format(wikidata_id))
        self.wikidata_entry = wikidata_entry

def handle_wikidata_api_result(result, wikidata_entries, languages, get_kind=config.wikidata.get_kind):
    if 'error' in result:
        if result['error']['code'] == 'no-such-entity':
            wikidata_id = result['error']['id']
            for wikidata_entry in wikidata_entries:
                if wikidata_entry.id == wikidata_id:
                    logger.warning("No such entity for Wikidata ID {}".format(wikidata_id))
                    wikidata_entry.delete()
                    raise WikidataAPINoSuchEntityError(result['error']['info'], wikidata_entry)
        raise WikidataAPIError(result['error']['info'])
    for wikidata_entry in wikidata_entries:
        entity = result['entities'][wikidata_entry.id]
        if 'missing' in entity:
            wikidata_id = wikidata_entry.id
            logger.warning("Missing entity for Wikidata ID {}".format(wikidata_id))
            wikidata_entry.delete()
            raise WikidataAPIMissingEntityError(wikidata_id, wikidata_entry)
        wikidata_entry.raw_labels = json.dumps(entity['labels'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.raw_descriptions = json.dumps(entity['descriptions'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.raw_claims = json.dumps(entity['claims'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.raw_sitelinks = json.dumps(entity['sitelinks'], ensure_ascii=False, indent=4, separators=(',', ': '))
        wikidata_entry.kind = get_kind(wikidata_entry)
        if not wikidata_entry.kind:
            logger.warning("Wikidata entry {} does not have not a recognized kind".format(wikidata_entry))
            wikidata_entry.kind = ""

        # Check labels and descriptions for each language
        name = None
        for language in languages:
            if not language in entity['labels']:
                logger.warning("Label for language '{}' is missing for wikidata ID {}".format(language, wikidata_entry.id))
            elif not name:
                name = entity['labels'][language]['value']
            if not language in entity['descriptions']:
                logger.warning("Description for language '{}' is missing for wikidata ID {}".format(language, wikidata_entry.id))

        wikidata_entry.name = name if name else ""
        wikidata_entry.save()
