from superlachaise.models import *

BOUNDING_BOX = ((48.8575, 2.3877), (48.8649, 2.4006))

FETCHED_TAGS = [
    "historic=tomb",
    "historic=memorial"
]

def post_sync_openstreetmap_elements(openstreetmap_elements):
    pass

def get_openstreetmap_element_export_object(openstreetmap_element):
    (type, id) = openstreetmap_element.split_id()
    return {
        "type": type,
        "id": id,
        "name": openstreetmap_element.name,
        "latitude": str(openstreetmap_element.latitude),
        "longitude": str(openstreetmap_element.longitude),
        "wikidata_entry": openstreetmap_element.wikidata_entry.id if openstreetmap_element.wikidata_entry else None,
    }
