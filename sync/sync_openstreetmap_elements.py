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
    logger.info('== begin sync openstreetmap elements ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(OpenstreetmapElement.objects.all())

    logger.info("Request {}".format(OVERPASS_API_BASE_URL))
    if ids:
        overpass_subqueries = make_overpass_elements_subqueries(ids)
    else:
        overpass_subqueries = make_overpass_area_subqueries()
    overpass_query = make_overpass_query(overpass_subqueries)
    overpass_elements = request_overpass_elements(overpass_query)

    logger.info("Update model")
    openstreetmap_elements, created = update_model(overpass_elements)
    logger.info("Refreshed {} Openstreetmap elements to refresh (created {})".format(len(openstreetmap_elements), created))
    config.openstreetmap.post_sync_openstreetmap_elements(openstreetmap_elements)

    orphaned_objects = [openstreetmap_element for openstreetmap_element in orphaned_objects if openstreetmap_element not in openstreetmap_elements]

    for openstreetmap_element in orphaned_objects:
        logger.debug("Deleted OpenstreetmapElement "+openstreetmap_element.id)
        openstreetmap_element.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync openstreetmap elements ==')

def delete_objects():
    OpenstreetmapElement.objects.all().delete()

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
    logger.debug("overpass_query:")
    logger.debug(overpass_query)

    # Kill any other query
    sync_utils.request(OVERPASS_API_BASE_URL+'kill_my_queries')

    # Request data
    result = sync_utils.request(OVERPASS_API_BASE_URL+'interpreter', "post", data=overpass_query)

    # Get elements from JSON
    return result.json()["elements"]

# Update model

def get_or_create_openstreetmap_element(overpass_element):
    openstreetmap_id = "{type}/{id}".format(type=overpass_element["type"], id=overpass_element["id"])
    openstreetmap_element, created = OpenstreetmapElement.objects.get_or_create(id=openstreetmap_id)
    if "name" in overpass_element["tags"]:
        openstreetmap_element.name = overpass_element["tags"]["name"]
    else:
        logger.warning("Name is missing for {}".format(openstreetmap_id))
        openstreetmap_element.name = ""
    if "center" in overpass_element:
        coordinate_node = overpass_element["center"]
    else:
        coordinate_node = overpass_element
    openstreetmap_element.latitude = coordinate_node["lat"]
    openstreetmap_element.longitude = coordinate_node["lon"]
    openstreetmap_element.raw_tags = json.dumps(overpass_element["tags"], ensure_ascii=False, indent=4, separators=(',', ': '))
    openstreetmap_element.save()
    return (openstreetmap_element, created)

def update_model(overpass_elements):
    created = 0
    openstreetmap_elements = []

    for overpass_element in overpass_elements:
        openstreetmap_element, was_created = get_or_create_openstreetmap_element(overpass_element)
        if openstreetmap_element:
            if was_created:
                logger.debug("Created OpenstreetmapElement "+openstreetmap_element.id)
                created = created + 1
            else:
                logger.debug("Matched OpenstreetmapElement "+openstreetmap_element.id)
            if not openstreetmap_element in openstreetmap_elements:
                openstreetmap_elements.append(openstreetmap_element)

    return (openstreetmap_elements, created)
