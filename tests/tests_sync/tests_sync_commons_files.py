import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

class SyncCommonsFilesTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_commons_files(self):
        commons_file = CommonsFile(id="Jim Morrison")
        commons_file.save()
        sync_commons_files.delete_objects()
        self.assertEqual(CommonsFile.objects.all().count(), 0)
