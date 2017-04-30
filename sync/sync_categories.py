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
    logger.info('== begin sync categories ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    configured_categories = config.category.CATEGORIES

    categories_to_refresh, created = get_or_create_categories_to_refresh(ids, configured_categories)
    logger.info("Found {} categories to refresh (created {})".format(len(categories_to_refresh), created))

    refresh_categories(categories_to_refresh, configured_categories)

    if not ids:
        logger.info('Export categories')
        export_categories(categories_to_refresh)

    logger.info('== end sync categories ==')

def delete_objects():
    Category.objects.all().delete()

# Prepare model

def get_or_create_categories_to_refresh(ids, configured_categories):
    if ids:
        return (list(Category.objects.filter(id__in=ids)), 0)
    else:
        categories = list(Category.objects.all())
        created = 0
        for category_id in configured_categories.keys():
            category, was_created = Category.objects.get_or_create(id=category_id)
            if not category in categories:
                categories.append(category)
            if was_created:
                logger.debug("Created Category "+category.id)
                created = created + 1
            else:
                logger.debug("Matched Category "+category.id)
        return (categories, created)

def refresh_categories(categories_to_refresh, configured_categories):
    for category in categories_to_refresh:
        if category.id in configured_categories:
            logger.debug("Refresh Category {category_id} from configured categories".format(category_id=category.id))
            category_dict = configured_categories[category.id]
            category.kind = category_dict['kind']
            category.raw_labels = json.dumps(category_dict['labels'], ensure_ascii=False, indent=4, separators=(',', ': '))
            category.save()
            for wikidata_category_id in category_dict['wikidata_categories']:
                try:
                   wikidata_category = WikidataCategory.objects.get(id=wikidata_category_id)
                   if not wikidata_category.category:
                       wikidata_category.category = category
                       wikidata_category.save()
                except WikidataCategory.DoesNotExist:
                   logger.warning("No such Wikidata occupation {}".format(wikidata_category_id))

def export_categories(categories):
    categories_object = {category.id: category.json_object() for category in categories}

    with open(os.path.join(settings.SUPERLACHAISE_EXPORTS, 'categories.json'), 'w') as export_file:
        export_file.write(json.dumps(categories_object, ensure_ascii=False, indent=4, separators=(',', ': '), sort_keys=True))
