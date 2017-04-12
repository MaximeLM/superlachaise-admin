import sys
import logging
from django.core.management.base import BaseCommand, CommandError

from superlachaise.sync import *

logger = logging.getLogger(__name__)

class Command(BaseCommand):

    TARGETS = [
        "openstreetmap_elements",
        "wikidata_entries",
        "wikipedia_pages",
        "commons_categories",
    ]

    def add_arguments(self, parser):
        parser.add_argument(
            'target',
            type=str,
            choices=Command.TARGETS,
            help='The specific target to sync',
        )
        parser.add_argument(
            '--ids',
            action='append',
            default=None,
            dest='ids',
            help='The IDs of the objects to sync (unavailable for all target); use multiple times to add more IDs.',
        )
        parser.add_argument(
            '--reset', '-r',
            action='store_true',
            dest='reset',
            default=False,
            help='Delete existing data before syncing',
        )

    def handle(self, *args, **options):
        target = options['target']
        module_name = "superlachaise.sync.sync_{}".format(target)
        try:
            sys.modules[module_name].sync(**options)
        except Exception as err:
            logger.critical(err)
            raise CommandError(err)
