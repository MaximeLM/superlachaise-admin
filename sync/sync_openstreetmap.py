import logging
import os
import importlib.machinery
import requests
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False):
    logger.info('== Sync OpenStreetMap ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    logger.info('Request Overpass API')
    overpass_query = make_overpass_query(make_overpass_area_subqueries())
    overpass_result = request_overpass(overpass_query)

def delete_objects():
    OpenStreetMapElement.objects.all().delete()

# Overpass

OVERPASS_AREA_SUBQUERY_FORMAT = "{type}[{tag}]({bounding_box});"
def make_overpass_area_subqueries(
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
def make_overpass_elements_subqueries(openstreetmap_elements):
    return [OVERPASS_ELEMENT_SUBQUERY_FORMAT.format(type=openstreetmap_element.id.split('/')[0], id=openstreetmap_element.id.split('/')[1]) for openstreetmap_element in openstreetmap_elements]

OVERPASS_QUERY_FORMAT = "[out:json];({subqueries});out center;"
def make_overpass_query(overpass_subqueries):
    return OVERPASS_QUERY_FORMAT.format(subqueries="".join(overpass_subqueries))

OVERPASS_API_BASE_URL = "https://overpass-api.de/api/"
def request_overpass(overpass_query):
    logger.debug("Overpass query:")
    logger.debug(overpass_query)

    # Kill any other query
    sync_utils.request(OVERPASS_API_BASE_URL+'kill_my_queries')

    # Request data
    result = sync_utils.request(OVERPASS_API_BASE_URL+'interpreter', "post", data=overpass_query)

    return result.json()
