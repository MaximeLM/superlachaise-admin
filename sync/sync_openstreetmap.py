import logging

from superlachaise.models import *

logger = logging.getLogger(__name__)

def sync(reset=False):
    logger.info('== Sync OpenStreetMap ==')
    if reset:
        delete_objects()

def delete_objects():
    logger.info('Deleting existing objects')
    OpenStreetMapElement.objects.all().delete()
