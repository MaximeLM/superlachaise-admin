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

    # make_overpass_area_subqueries

    def test_make_overpass_area_subqueries_with_no_fetched_tags_returns_empty_array(self):
        bounding_box = ((48.8575, 2.3877), (48.8649, 2.4006))
        fetched_tags = []
        self.assertEqual(
            sync_openstreetmap.make_overpass_area_subqueries(bounding_box, fetched_tags),
            [])

    def test_make_overpass_area_subqueries_returns_combined_subqueries_with_format(self):
        bounding_box = ((48.8575, 2.3877), (48.8649, 2.4006))
        fetched_tags = ["historic=tomb", "historic=memorial"]
        expected_bounding_box_string="48.8575,2.3877,48.8649,2.4006"
        self.assertEqual(
            sync_openstreetmap.make_overpass_area_subqueries(bounding_box, fetched_tags),
            [
            sync_openstreetmap.OVERPASS_AREA_SUBQUERY_FORMAT.format(type="node", tag=fetched_tags[0], bounding_box=expected_bounding_box_string),
            sync_openstreetmap.OVERPASS_AREA_SUBQUERY_FORMAT.format(type="way", tag=fetched_tags[0], bounding_box=expected_bounding_box_string),
            sync_openstreetmap.OVERPASS_AREA_SUBQUERY_FORMAT.format(type="relation", tag=fetched_tags[0], bounding_box=expected_bounding_box_string),
            sync_openstreetmap.OVERPASS_AREA_SUBQUERY_FORMAT.format(type="node", tag=fetched_tags[1], bounding_box=expected_bounding_box_string),
            sync_openstreetmap.OVERPASS_AREA_SUBQUERY_FORMAT.format(type="way", tag=fetched_tags[1], bounding_box=expected_bounding_box_string),
            sync_openstreetmap.OVERPASS_AREA_SUBQUERY_FORMAT.format(type="relation", tag=fetched_tags[1], bounding_box=expected_bounding_box_string),
            ])

    # make_overpass_elements_subqueries

    def test_make_overpass_elements_subqueries_with_no_ids_returns_empty_array(self):
        self.assertEqual(sync_openstreetmap.make_overpass_elements_subqueries([]),[])

    def test_make_overpass_elements_subqueries_returns_subqueries_with_format(self):
        ids = [
            "way/123456",
            "relation/654321",
            "node/789654",
        ]
        self.assertEqual(
            sync_openstreetmap.make_overpass_elements_subqueries(ids),
            [
            sync_openstreetmap.OVERPASS_ELEMENT_SUBQUERY_FORMAT.format(type="way", id="123456"),
            sync_openstreetmap.OVERPASS_ELEMENT_SUBQUERY_FORMAT.format(type="relation", id="654321"),
            sync_openstreetmap.OVERPASS_ELEMENT_SUBQUERY_FORMAT.format(type="node", id="789654"),
            ])

    # make_overpass_query

    def test_make_overpass_query_with_no_subqueries_returns_no_subqueries_with_format(self):
        self.assertEqual(
            sync_openstreetmap.make_overpass_query([]),
            sync_openstreetmap.OVERPASS_QUERY_FORMAT.format(subqueries="")
        )

    def test_make_overpass_query_returns_subqueries_with_format(self):
        subqueries = [
            "subquery1;",
            "subquery2;"
        ]
        self.assertEqual(
            sync_openstreetmap.make_overpass_query(subqueries),
            sync_openstreetmap.OVERPASS_QUERY_FORMAT.format(subqueries="subquery1;subquery2;")
        )
