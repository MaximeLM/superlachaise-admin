from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

class SyncOpenstreetmapTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_openstreetmap_elements(self):
        openstreetmap_element = OpenStreetMapElement(id="node/123456")
        openstreetmap_element.save()
        sync_openstreetmap.delete_objects()
        self.assertEqual(OpenStreetMapElement.objects.all().count(), 0)

    # make_overpass_subqueries
