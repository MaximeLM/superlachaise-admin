from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

class SyncWikidataTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_wikidata_entries(self):
        wikidata_entry = WikidataEntry(id="Q123456")
        wikidata_entry.save()
        sync_wikidata.delete_objects()
        self.assertEqual(WikidataEntry.objects.all().count(), 0)
