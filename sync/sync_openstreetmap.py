import logging
import os
import importlib.machinery
import requests
import json
from django.conf import settings
from requests.exceptions import RequestException
from json.decoder import JSONDecodeError

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync openstreetmap ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    logger.info('Request Overpass API')
    if ids:
        overpass_subqueries = make_overpass_elements_subqueries(ids.split('|'))
    else:
        overpass_subqueries = make_overpass_area_subqueries()
    overpass_query = make_overpass_query(overpass_subqueries)
    overpass_elements = request_overpass_elements(overpass_query)

    logger.info("Fetched {} elements".format(len(overpass_elements)))

    created, updated, deleted = update_model(overpass_elements, get_local_openstreetmap_elements(ids))

    logger.info("Created {} elements".format(created))
    logger.info("Updated {} elements".format(updated))
    logger.info("Deleted {} elements".format(deleted))

    logger.info('== end sync openstreetmap ==')

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
def make_overpass_elements_subqueries(ids):
    return [OVERPASS_ELEMENT_SUBQUERY_FORMAT.format(type=id.split('/')[0], id=id.split('/')[1]) for id in ids]

OVERPASS_QUERY_FORMAT = "[out:json];({subqueries});out center;"
def make_overpass_query(overpass_subqueries):
    return OVERPASS_QUERY_FORMAT.format(subqueries="".join(overpass_subqueries))

OVERPASS_API_BASE_URL = "https://overpass-api.de/api/"
def request_overpass_elements(overpass_query):
    logger.debug("Overpass query:")
    logger.debug(overpass_query)

    # Kill any other query
    sync_utils.request(OVERPASS_API_BASE_URL+'kill_my_queries')

    # Request data
    result = sync_utils.request(OVERPASS_API_BASE_URL+'interpreter', "post", data=overpass_query)

    # Get elements from JSON
    return result.json()["elements"]

# Update model

def get_or_create_openstreetmap_element(
    overpass_element,
    excluded_identifiers=config.openstreetmap.EXCLUDE_IDENTIFIERS):
    id = "{type}/{id}".format(type=overpass_element["type"], id=overpass_element["id"])
    if id in excluded_identifiers:
        return (None, False)
    else:
        openstreetmap_element, created = OpenStreetMapElement.objects.get_or_create(id=id)
        if "center" in overpass_element:
            coordinate_node = overpass_element["center"]
        else:
            coordinate_node = overpass_element
        openstreetmap_element.latitude = coordinate_node["lat"]
        openstreetmap_element.longitude = coordinate_node["lon"]
        openstreetmap_element.raw_tags = json.dumps(overpass_element["tags"])
        openstreetmap_element.save()
        return (openstreetmap_element, created)

def get_local_openstreetmap_elements(ids=None):
    if ids:
        return list(OpenStreetMapElement.objects.filter(id__in=ids))
    else:
        return list(OpenStreetMapElement.objects.all())

def update_model(overpass_elements, local_openstreetmap_elements):
    created = 0
    updated = 0
    deleted = 0

    for overpass_element in overpass_elements:
        openstreetmap_element, was_created = get_or_create_openstreetmap_element(overpass_element)
        if openstreetmap_element:
            if was_created:
                logger.debug("Created OpenStreetMapElement "+openstreetmap_element.id)
                created = created + 1
            else:
                logger.debug("Updated OpenStreetMapElement "+openstreetmap_element.id)
                updated = updated + 1
            if openstreetmap_element in local_openstreetmap_elements:
                local_openstreetmap_elements.remove(openstreetmap_element)

    for openstreetmap_element in local_openstreetmap_elements:
        logger.debug("Deleted OpenStreetMapElement "+openstreetmap_element.id)
        deleted = deleted + 1
        openstreetmap_element.delete()

    return (created, updated, deleted)
