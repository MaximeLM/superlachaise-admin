import logging, os, importlib.machinery, json, re
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync store v1 node ID mappings ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    configured_mappings = config.storev1.NODE_ID_MAPPINGS

    orphaned_objects = [] if ids else list(StoreV1NodeIDMapping.objects.all())

    mappings_to_refresh, created = get_or_create_mappings_to_refresh(ids, configured_mappings)
    logger.info("Found {} mappings to refresh (created {})".format(len(mappings_to_refresh), created))
    orphaned_objects = [mapping for mapping in orphaned_objects if mapping not in mappings_to_refresh]

    resolve_mappings(mappings_to_refresh, configured_mappings)

    if not ids:
        logger.info('Export mappings')
        export_mappings(mappings_to_refresh)

    for mapping in orphaned_objects:
        logger.debug("Deleted StoreV1NodeIDMapping "+str(mapping))
        mapping.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync store v1 node ID mappings ==')

def delete_objects():
    StoreV1NodeIDMapping.objects.all().delete()

def get_or_create_mappings_to_refresh(ids, configured_mappings):
    if ids:
        return (list(StoreV1NodeIDMapping.objects.filter(id__in=ids)), 0)
    else:
        node_id_mappings = []
        created = 0
        for (node_id_mapping_dict) in configured_mappings:
            node_id_mapping, was_created = StoreV1NodeIDMapping.objects.get_or_create(id=node_id_mapping_dict['id'])
            if not node_id_mapping in node_id_mappings:
                node_id_mappings.append(node_id_mapping)
            if was_created:
                logger.debug("Created StoreV1NodeIDMapping "+str(node_id_mapping))
                created = created + 1
            else:
                logger.debug("Matched StoreV1NodeIDMapping "+str(node_id_mapping))
        return (node_id_mappings, created)

def resolve_mappings(mappings, configured_mappings):
    configured_mappings_by_id = {mapping_dict['id']: mapping_dict for mapping_dict in configured_mappings}
    for mapping in mappings:
        if mapping.id in configured_mappings_by_id:
            mapping_dict = configured_mappings_by_id[mapping.id]
            logger.debug("Refresh mapping {mapping_id} from configured mappings".format(mapping_id=mapping.id))
            wikidata_entry_id = mapping_dict['wikidata_entry']
            if wikidata_entry_id:
                try:
                    wikidata_entry = WikidataEntry.objects.get(id=wikidata_entry_id)
                    if not mapping.wikidata_entry:
                        mapping.wikidata_entry = wikidata_entry
                except WikidataEntry.DoesNotExist:
                    logger.warning("No such Wikidata entry {}".format(wikidata_entry_id))
            matching_openstreetmap_elements = OpenstreetmapElement.objects.filter(numeric_id=mapping.id)
            if len(matching_openstreetmap_elements) == 0:
                if not mapping.wikidata_entry:
                    logger.warning("Could not find a matching OpenstreetmapElement for mapping "+str(mapping))
            if len(matching_openstreetmap_elements) > 1:
                if not mapping.wikidata_entry:
                    logger.warning("Too many matching OpenstreetmapElements for mapping "+str(mapping))
            if len(matching_openstreetmap_elements) == 1:
                matching_wikidata_entry = matching_openstreetmap_elements[0].wikidata_entry
                if matching_wikidata_entry:
                    if mapping.wikidata_entry and mapping.wikidata_entry.id != matching_wikidata_entry.id:
                        logger.warning("Current wikidata entry does not match OpenstreetmapElement for mapping "+str(mapping))
                    else:
                        mapping.wikidata_entry = matching_wikidata_entry
                else:
                    logger.warning("Matching OpenstreetmapElement {} has no wikidata entry for mapping {}".format(str(matching_openstreetmap_elements[0]), str(mapping)))
            mapping.save()

def export_mappings(mappings):
    config_object = [{
        "id": mapping.id,
        "wikidata_entry": mapping.wikidata_entry.id if mapping.wikidata_entry else '',
    } for mapping in mappings]

    with open(os.path.join(settings.SUPERLACHAISE_CONFIG, 'storev1_node_id_mappings_exported.py'), 'w') as export_file:
        export_file.write("NODE_ID_MAPPINGS = " + json.dumps(config_object, ensure_ascii=False, indent=4, separators=(',', ': '), sort_keys=True))
