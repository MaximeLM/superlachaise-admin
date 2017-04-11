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

    for commons_category in orphaned_objects:
        logger.debug("Deleted CommonsCategory "+commons_category.id)
        commons_category.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_object)))

    logger.info('== end sync commons categories ==')

def delete_objects():
    CommonsCategory.objects.all().delete()
