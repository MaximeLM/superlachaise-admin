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

    logger.info('== end sync wikipedia pages ==')

def delete_objects():
    WikipediaPage.objects.all().delete()
