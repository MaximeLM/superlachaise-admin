import logging

from superlachaise.models import *

logger = logging.getLogger("superlachaise")

BOUNDING_BOX = ((48.8575, 2.3877), (48.8649, 2.4006))

FETCHED_TAGS = [
    "historic=tomb",
    "historic=memorial",
]

def get_wikidata_entry_id(openstreetmap_element):
    map_ids = {

    }
    tags = openstreetmap_element.tags()
    wikidata_tag = None
    if "wikidata" in tags:
        wikidata_tag = tags["wikidata"]
    if not wikidata_tag and "name:wikidata" in tags:
        wikidata_tag = tags["name:wikidata"]
    if wikidata_tag and wikidata_tag in map_ids:
        new_tag = map_ids[wikidata_tag]
        logger.debug("Replacing {} with {}".format(wikidata_tag, new_tag))
        wikidata_tag = new_tag
    return wikidata_tag

def get_openstreetmap_export_object(config):
    openstreetmap_elements = OpenstreetmapElement.objects.filter(wikidata_entry__isnull=False)
    export_object = {
        "about": {
            "source": "http://www.openstreetmap.org/",
            "license": "http://www.openstreetmap.org/copyright/",
        },
        "openstreetmap_elements": {}
    }

    for openstreetmap_element in openstreetmap_elements:
        openstreetmap_element_dict = get_openstreetmap_element_export_object(openstreetmap_element, config)
        export_object["openstreetmap_elements"].update(openstreetmap_element_dict)

    return export_object

def get_openstreetmap_element_export_object(openstreetmap_element, config):
    wikidata_entry = config.wikidata.get_notable_wikidata_entry(openstreetmap_element.wikidata_entry) if openstreetmap_element.wikidata_entry else None
    if not wikidata_entry:
        return {}
    return {
        openstreetmap_element.id:{
            "element_type": openstreetmap_element.element_type,
            "numeric_id": openstreetmap_element.numeric_id,
            "name": openstreetmap_element.name,
            "latitude": float(openstreetmap_element.latitude),
            "longitude": float(openstreetmap_element.longitude),
            "wikidata_entry": wikidata_entry.id if wikidata_entry else None,
        }
    }
