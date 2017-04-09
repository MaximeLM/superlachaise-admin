import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

class SyncWikipediaPagesTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_wikipedia_pages(self):
        wikipedia_page = WikipediaPage(id="fr|Jim_Morrison")
        wikipedia_page.save()
        sync_wikipedia_pages.delete_objects()
        self.assertEqual(WikipediaPage.objects.all().count(), 0)
