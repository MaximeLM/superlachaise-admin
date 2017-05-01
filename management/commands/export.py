import sys
import logging
import importlib.machinery
import json
import os
from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *

logger = logging.getLogger(__name__)

class Command(BaseCommand):

    TARGETS = {
        "openstreetmap": config.openstreetmap.get_openstreetmap_export_object,
        "wikidata": config.wikidata.get_wikidata_export_object,
        #"wikipedia": [],
        #"commons": [],
        #"category": [],
        "all": [],
    }

    def export(self, target, getter):
        export_object = {}
        export_object.update(getter(config))
        with open(os.path.join(settings.SUPERLACHAISE_EXPORTS, target+'.json'), 'w') as export_file:
            export_file.write(json.dumps(export_object, ensure_ascii=False, indent=4, separators=(',', ': '), sort_keys=True))

    def add_arguments(self, parser):
        parser.add_argument(
            'target',
            type=str,
            choices=Command.TARGETS.keys(),
            help='The specific target to export',
        )

    def handle(self, *args, **options):
        target = options.pop('target')
        if target == "all":
            for (target, getter) in Command.TARGETS.items():
                if target != "all":
                    self.export(target, getter)
        else:
            self.export(target, Command.TARGETS[target])
