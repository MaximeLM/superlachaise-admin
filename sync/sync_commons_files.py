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
    logger.info('== begin sync commons files ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(CommonsFile.objects.all())

    commons_files_to_refresh, created = get_or_create_commons_files_to_refresh(ids)
    logger.info("Found {} Commons files to refresh (created {})".format(len(commons_files_to_refresh), created))
    orphaned_objects = [commons_file for commons_file in orphaned_objects if commons_file not in commons_files_to_refresh]

    for commons_file in orphaned_objects:
        logger.debug("Deleted CommonsFile "+commons_file.id)
        commons_file.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync commons files ==')

def delete_objects():
    CommonsFile.objects.all().delete()

# Prepare model

def get_or_create_main_commons_files_from_commons_categories(commons_categories):
    created = 0
    main_commons_files = []
    for commons_category in commons_categories:
        main_commons_file_id = commons_category.image
        if main_commons_file_id:
            main_commons_file, was_created = CommonsFile.objects.get_or_create(id=main_commons_file_id)
            if was_created:
                logger.debug("Created main CommonsFile "+main_commons_file.id)
                created = created + 1
            else:
                logger.debug("Matched main CommonsFile "+main_commons_file.id)
            commons_category.main_commons_file = main_commons_file
            if not main_commons_file in main_commons_files:
                main_commons_files.append(main_commons_file)
        else:
            commons_category.main_commons_file = None
        commons_category.save()
    return (main_commons_files, created)

def get_or_create_commons_files_to_refresh(ids):
    if ids:
        return (list(CommonsFile.objects.filter(id__in=ids)), 0)
    else:
        commons_categories = list(CommonsCategory.objects.all())
        logger.info('List main Commons files from Commons categories')
        main_commons_files, main_created =  get_or_create_main_commons_files_from_commons_categories(commons_categories)
        category_members, members_created = request_category_members(commons_categories)
        commons_files = main_commons_files
        commons_files.extend([commons_file for commons_file in category_members if commons_file not in commons_files])
        return (commons_files, main_created + members_created)

# Request Commons API

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

# Request category members

def make_category_members_query_params(commons_category):
    return {
        'action': 'query',
        'list': 'categorymembers',
        'cmtype': 'file',
        'format': 'json',
        'cmtitle': "Category:"+commons_category.id,
    }

def request_category_members(commons_categories):
    logger.info("Request {} for category members".format(COMMONS_API_BASE_URL))
    entry_count = 0
    entry_total = len(commons_categories)
    commons_files = []
    created = 0
    for commons_categories_chunk in sync_utils.make_chunks(list(commons_categories)):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(commons_categories_chunk)

        for commons_category in commons_categories_chunk:
            commons_files_for_category = []
            category_members_query_params = make_category_members_query_params(commons_category)
            last_continue = {'continue': ''}
            while last_continue:
                logger.debug("last_continue: {}".format(last_continue))
                category_members_query_params.update(last_continue)
                result = request_commons_api(category_members_query_params)
                last_continue, request_commons_files, request_created = handle_category_members_result(result)
                created = created + request_created
                commons_files_for_category.extend([commons_file for commons_file in request_commons_files if commons_file not in commons_files_for_category])

            # Check and save commons category
            if len(commons_files_for_category) == 0:
                logger.warning("No Commons files found for Commons category \"{}\"".format(commons_category.id))
            commons_category.commons_files.set(commons_files_for_category)
            commons_files.extend([commons_file for commons_file in commons_files_for_category if commons_file not in commons_files])

    logger.info(str(entry_count)+"/"+str(entry_total))
    return (commons_files, created)

def handle_category_members_result(result):
    created = 0
    commons_files = []
    if 'error' in result:
        raise CommonsAPIError(result['error']['info'])
    for commons_file_dict in result['query']['categorymembers']:
        title = commons_file_dict['title'].split("File:")[1]
        commons_file, was_created = CommonsFile.objects.get_or_create(id=title)
        if was_created:
            logger.debug("Created CommonsFile "+commons_file.id)
            created = created + 1
        else:
            logger.debug("Matched CommonsFile "+commons_file.id)
        if not commons_file in commons_files:
            commons_files.append(commons_file)
    contine = result['continue'] if 'continue' in result else None
    return (contine, commons_files, created)
