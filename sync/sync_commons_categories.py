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
