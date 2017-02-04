import sys
from django.core.management.base import BaseCommand

import superlachaise.sync
from superlachaise.sync import *

class Command(BaseCommand):

    def add_arguments(self, parser):
        parser.add_argument(
            'target',
            type=str,
            choices=[module.split('sync_')[1] for module in superlachaise.sync.__all__ if module.startswith('sync_')],
            help='The specific target to sync',
        )
        parser.add_argument(
            '--reset', '-r',
            action='store_true',
            dest='reset',
            default=False,
            help='Delete existing data before syncing',
        )

    def handle(self, *args, **options):
        module_name = "superlachaise.sync.sync_{}".format(options['target'])
        sys.modules[module_name].sync(options['reset'])
