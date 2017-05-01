import logging

from superlachaise.models import *

logger = logging.getLogger("superlachaise")

BOUNDING_BOX = ((48.8575, 2.3877), (48.8649, 2.4006))

FETCHED_TAGS = [
    "historic=tomb",
    "historic=memorial",
]

WIKIDATA_TAGS = [
    "wikidata",
    "name:wikidata",
]

def post_refresh_openstreetmap_elements(openstreetmap_elements):
    exclude_ids = [
        "node/1688357881",  # not in the cemetery
    ]
    filtered_openstreetmap_elements = []
    for openstreetmap_element in openstreetmap_elements:
        if openstreetmap_element.id in exclude_ids:
            logger.debug("Deleted exluded Openstreetmap element "+openstreetmap_element.id)
            openstreetmap_element.delete()
        else:
            filtered_openstreetmap_elements.append(openstreetmap_element)
    return filtered_openstreetmap_elements

def get_openstreetmap_export_object(config):
    openstreetmap_elements = OpenstreetmapElement.objects.filter(wikidata_entry__isnull=False)
    return {
        "about": {
            "source": "http://www.openstreetmap.org/",
            "license": "http://www.openstreetmap.org/copyright/",
        },
        "openstreetmap_elements": {openstreetmap_element.id: get_openstreetmap_element_export_object(openstreetmap_element) for openstreetmap_element in openstreetmap_elements},
    }

def get_openstreetmap_element_export_object(openstreetmap_element):
    (type, id) = openstreetmap_element.split_id()
    return {
        "type": type,
        "id": int(id),
        "name": openstreetmap_element.name,
        "latitude": float(openstreetmap_element.latitude),
        "longitude": float(openstreetmap_element.longitude),
        "wikidata_entry": openstreetmap_element.wikidata_entry.id if openstreetmap_element.wikidata_entry else None,
    }
