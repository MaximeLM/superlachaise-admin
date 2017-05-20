import logging, os, importlib.machinery, json, re
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync commons files ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(CommonsFile.objects.all())

    commons_files_to_refresh, created = get_or_create_commons_categories_to_refresh(ids)
    logger.info("Found {} Commons files to refresh (created {})".format(len(commons_files_to_refresh), created))
    orphaned_objects = [commons_file for commons_file in orphaned_objects if commons_file not in commons_files_to_refresh]

    for commons_file in orphaned_objects:
        logger.debug("Deleted CommonsFile "+commons_file.id)
        commons_file.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync commons files ==')

def delete_objects():
    CommonsFile.objects.all().delete()

def get_commons_files_from_commons_categories(commons_categories):
    commons_files, created = ([], 0)

    logger.info("Request {}".format(COMMONS_API_BASE_URL))
    entry_count = 0
    entry_total = len(commons_categories)
    for commons_categories_chunk in sync_utils.make_chunks(list(commons_categories)):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(commons_categories_chunk)

        for commons_category in commons_categories_chunk:
            commons_files_for_category, created_for_category = get_commons_files_from_commons_category(commons_category)
            commons_files.extend([commons_file for commons_file in commons_files_for_category if commons_file not in commons_files])
            created = created + created_for_category

    return (commons_files, created)

def get_commons_files_from_commons_category(commons_category):
    commons_files, created = request_category_members(commons_category)

    main_commons_file_id = commons_category.get_main_commons_file_id()
    if main_commons_file_id:
        main_commons_file, was_created = CommonsFile.objects.get_or_create(id=main_commons_file_id)
        if not main_commons_file in commons_files:
            commons_files.append(main_commons_file)
            logger.warning("Main Commons file not in category members for Commons category {}".format(commons_category))
        if was_created:
            logger.debug("Created CommonsFile "+main_commons_file.id)
            created = created + 1
        else:
            logger.debug("Matched CommonsFile "+main_commons_file.id)
        commons_category.main_commons_file = main_commons_file
        commons_category.save()

    return (commons_files, created)

def get_or_create_commons_categories_to_refresh(ids):
    if ids:
        return (list(CommonsFile.objects.filter(id__in=ids)), 0)
    else:
        logger.info('Get Commons files from Commons categories')
        return get_commons_files_from_commons_categories(list(CommonsCategory.objects.all()))

# Request Commons

COMMONS_API_BASE_URL = "https://commons.wikimedia.org/w/api.php"
def request_commons_api(commons_query_params):
    logger.debug("commons_query_params:")
    logger.debug(commons_query_params)

    # Request data
    result = sync_utils.request(COMMONS_API_BASE_URL, params=commons_query_params)

    # Return JSON
    return result.json()

class CommonsAPIError(Exception):
    pass

# Category members

def make_category_members_query_params(commons_category):
    return {
        'action': 'query',
        'list': 'categorymembers',
        'cmtitle': 'Category:'+commons_category.id,
        'cmtype': 'file',
        'format': 'json',
    }

def request_category_members(commons_category):
    commons_files = []
    created = 0

    commons_query_params = make_category_members_query_params(commons_category)
    last_continue = {'continue': ''}
    while last_continue:
        logger.debug("last_continue: {}".format(last_continue))
        commons_query_params.update(last_continue)
        result = request_commons_api(commons_query_params)
        last_continue, commons_files_for_page, created_for_page = handle_category_members_result(result)
        commons_files.extend(commons_files_for_page)
        created = created + created_for_page

    commons_category.commons_files.set(commons_files)
    commons_category.save()
    return (commons_files, created)

def handle_category_members_result(result):
    commons_files = []
    created = 0

    if 'error' in result:
        raise CommonsAPIError(result['error']['info'])
    if 'normalized' in result['query']:
        for normalize in result['query']['normalized']:
            from_title = normalize['from']
            to_title = normalize['to']
            logger.warning("Commons category was normalized from \"{}\" to \"{}\"".format(from_title, to_title))
    for commons_file_dict in result['query']['categorymembers']:
        commons_file_id = commons_file_dict['title'][5:]
        commons_file, was_created = CommonsFile.objects.get_or_create(id=commons_file_id)
        if was_created:
            logger.debug("Created CommonsFile "+commons_file.id)
            created = created + 1
        else:
            logger.debug("Matched CommonsFile "+commons_file.id)
        if not commons_file in commons_files:
            commons_files.append(commons_file)
    return (result.get('continue', None), commons_files, created)
