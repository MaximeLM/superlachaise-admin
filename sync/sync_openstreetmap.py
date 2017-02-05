import logging
import os
import importlib.machinery
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *

logger = logging.getLogger(__name__)

def sync(reset=False):
    logger.info('== Sync OpenStreetMap ==')
    if reset:
        delete_objects()

def delete_objects():
    logger.info('Deleting existing objects')
    OpenStreetMapElement.objects.all().delete()

# Overpass

OVERPASS_AREA_SUBQUERY_FORMAT = "{type}[{tag}]({bounding_box});"
def overpass_area_subqueries(
    bounding_box=config.openstreetmap.BOUNDING_BOX,
    fetched_tags=config.openstreetmap.FETCHED_TAGS):
    bounding_box_string = "{},{},{},{}".format(
        bounding_box[0][0],
        bounding_box[0][1],
        bounding_box[1][0],
        bounding_box[1][1])
    combinations = [(type, tag) for tag in fetched_tags for type in ["node", "way", "relation"]]
    return [OVERPASS_AREA_SUBQUERY_FORMAT.format(type=type, tag=tag, bounding_box=bounding_box_string) for tag in fetched_tags for type in ["node", "way", "relation"]]

OVERPASS_ELEMENT_SUBQUERY_FORMAT = "{type}({id});"
def overpass_elements_subqueries(openstreetmap_elements):
    return [OVERPASS_ELEMENT_SUBQUERY_FORMAT.format(type=openstreetmap_element.id.split('/')[0], id=openstreetmap_element.id.split('/')[1]) for openstreetmap_element in openstreetmap_elements]
