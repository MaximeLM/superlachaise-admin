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

    orphaned_objects = [] if ids else list(CommonsCategory.objects.all())

    node_id_mappings_to_refresh, created = get_or_create_node_id_mappings_to_refresh(ids)
    logger.info("Found {} node ID mappings to refresh (created {})".format(len(node_id_mappings_to_refresh), created))
    orphaned_objects = [node_id_mapping for node_id_mapping in orphaned_objects if node_id_mapping not in node_id_mappings_to_refresh]

    resolve_node_id_mappings(node_id_mappings_to_refresh)

    for storev1_node_id_mapping in orphaned_objects:
        logger.debug("Deleted StoreV1NodeIDMapping "+storev1_node_id_mapping.id)
        storev1_node_id_mapping.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync store v1 node ID mappings ==')

def delete_objects():
    StoreV1NodeIDMapping.objects.all().delete()

def get_or_create_node_id_mappings_to_refresh(ids):
    if ids:
        return (list(StoreV1NodeIDMapping.objects.filter(id__in=ids)), 0)
    else:
        return ([], 0)

def resolve_node_id_mappings(node_id_mappings):
    pass
