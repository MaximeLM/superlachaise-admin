import sys
import logging
from django.core.management.base import BaseCommand

from superlachaise.sync import *

logger = logging.getLogger(__name__)

class Command(BaseCommand):

    TARGETS = [
        "openstreetmap",
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
            type=str,
            dest='ids',
            help='The IDs of the objects to sync (unavailable for all target), separated by |',
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
        except Exception as e:
            logger.critical(e)
