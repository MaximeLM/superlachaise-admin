import logging, os, importlib.machinery, json
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync wikidata categories ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(WikidataCategory.objects.all())

    wikidata_categories_to_refresh, created = get_or_create_wikidata_categories_to_refresh(ids)
    logger.info("Found {} Wikidata categories to refresh (created {})".format(len(wikidata_categories_to_refresh), created))

    orphaned_objects = [wikidata_category for wikidata_category in orphaned_objects if wikidata_category not in wikidata_categories_to_refresh]

    logger.info("Request {}".format(WIKIDATA_API_BASE_URL))
    request_wikidata_categories(wikidata_categories_to_refresh)

    for wikidata_category in orphaned_objects:
        logger.debug("Deleted WikidataCategory "+wikidata_category.id)
        wikidata_category.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync wikidata categories ==')

def delete_objects():
    WikidataCategory.objects.all().delete()

# Prepare model

def get_or_create_wikidata_categories_from_wikidata_entries(wikidata_entries, get_wikidata_categories=config.wikidata.get_wikidata_categories):
    created = 0
    wikidata_categories = []
    for wikidata_entry in wikidata_entries:
        wikidata_categories_for_wikidata_entry = []
        for wikidata_category_id in get_wikidata_categories(wikidata_entry):
            wikidata_category, was_created = WikidataCategory.objects.get_or_create(id=wikidata_category_id)
            if not wikidata_category in wikidata_categories_for_wikidata_entry:
                wikidata_categories_for_wikidata_entry.append(wikidata_category)
            if was_created:
                logger.debug("Created WikidataCategory "+wikidata_category.id)
                created = created + 1
            else:
                logger.debug("Matched WikidataCategory "+wikidata_category.id)
        wikidata_entry.wikidata_categories.set(wikidata_categories_for_wikidata_entry)
        wikidata_categories.extend([wikidata_category for wikidata_category in wikidata_categories_for_wikidata_entry if wikidata_category not in wikidata_categories])
    return (wikidata_categories, created)

def get_or_create_wikidata_categories_to_refresh(ids):
    if ids:
        return (list(WikidataCategory.objects.filter(id__in=ids)), 0)
    else:
        logger.info('List Wikidata categories from Wikidata entries')
        return get_or_create_wikidata_categories_from_wikidata_entries(list(WikidataEntry.objects.all()))

# Request Wikidata

def make_wikidata_query_params(wikidata_categories, languages):
    return {
        'action': 'wbgetentities',
        'ids': '|'.join([wikidata_category.wikidata_id() for wikidata_category in wikidata_categories]),
        'props': '|'.join(['labels']),
        'languages': '|'.join(languages),
        'format': 'json',
    }

WIKIDATA_API_BASE_URL = "https://www.wikidata.org/w/api.php"
def request_wikidata_api(wikidata_query_params):
    logger.debug("wikidata_query_params:")
    logger.debug(wikidata_query_params)

    # Request data
    result = sync_utils.request(WIKIDATA_API_BASE_URL, params=wikidata_query_params)

    # Return JSON
    return result.json()

def request_wikidata_categories(wikidata_categories, languages=config.base.LANGUAGES):
    entry_count = 0
    entry_total = len(wikidata_categories)
    no_such_entity_entry_count = 0
    for wikidata_categories_chunk in sync_utils.make_chunks(list(wikidata_categories)):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(wikidata_categories_chunk)

        retry = True
        while retry:
            retry = False
            result = request_wikidata_api(make_wikidata_query_params(wikidata_categories_chunk, languages))
            try:
                handle_wikidata_api_result(result, wikidata_categories_chunk, languages)
            except (WikidataAPINoSuchEntityError, WikidataAPIMissingEntityError) as error:
                no_such_entity_entry_count = no_such_entity_entry_count + 1
                if error.wikidata_category in wikidata_categories_chunk:
                    wikidata_categories_chunk.remove(error.wikidata_category)
                    wikidata_categories.remove(error.wikidata_category)
                    retry = True

    logger.info(str(entry_count)+"/"+str(entry_total))
    if no_such_entity_entry_count > 0:
        logger.info("Deleted {} wikidata categories not found on Wikidata".format(no_such_entity_entry_count))
    config.wikidata.post_sync_wikidata_categories(wikidata_categories)

class WikidataAPIError(Exception):
    pass

class WikidataAPINoSuchEntityError(WikidataAPIError):
    def __init__(self, message, wikidata_category):
        super(WikidataAPINoSuchEntityError, self).__init__(message)
        self.wikidata_category = wikidata_category

class WikidataAPIMissingEntityError(WikidataAPIError):
    def __init__(self, wikidata_id, wikidata_category):
        super(WikidataAPIMissingEntityError, self).__init__("missing entity {}".format(wikidata_id))
        self.wikidata_category = wikidata_category

def handle_wikidata_api_result(result, wikidata_categories, languages):
    if 'error' in result:
        if result['error']['code'] == 'no-such-entity':
            wikidata_id = result['error']['id']
            for wikidata_category in wikidata_categories:
                if wikidata_category.wikidata_id() == wikidata_id:
                    logger.warning("No such entity for Wikidata ID {}".format(wikidata_id))
                    wikidata_category.delete()
                    raise WikidataAPINoSuchEntityError(result['error']['info'], wikidata_category)
        raise WikidataAPIError(result['error']['info'])
    for wikidata_category in wikidata_categories:
        entity = result['entities'][wikidata_category.wikidata_id()]
        if 'missing' in entity:
            wikidata_id = wikidata_category.wikidata_id()
            logger.warning("Missing entity for Wikidata ID {}".format(wikidata_id))
            wikidata_category.delete()
            raise WikidataAPIMissingEntityError(wikidata_id, wikidata_category)
        wikidata_category.raw_labels = json.dumps(entity['labels'], ensure_ascii=False, indent=4, separators=(',', ': '))

        # Check labels and descriptions for each language
        name = None
        for language in languages:
            if not language in entity['labels']:
                logger.warning("Label for language '{}' is missing for wikidata ID {}".format(language, wikidata_category.wikidata_id()))
            elif not name:
                name = entity['labels'][language]['value']

        wikidata_category.name = name if name else ""
        wikidata_category.save()
