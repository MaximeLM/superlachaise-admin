from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

# Fixtures

OVERPASS_ELEMENT_1 = {
    "type": "node",
    "id": 2765555563,
    "lat": 48.8618534,
    "lon": 2.3934719,
    "tags": {
        "historic": "tomb",
        "name": "Étienne Lamy",
        "sorting_name": "Lamy",
        "wikidata": "Q1218474",
        "wikimedia_commons": "Category:Grave of Lamy (Père-Lachaise, division 49)",
        "wikipedia": "fr:Étienne Lamy"
    }
}

OVERPASS_ELEMENT_2 = {
    "type": "way",
    "id": 314136876,
    "center": {
        "lat": 48.8583882,
        "lon": 2.3956719
    },
    "nodes": [
        3201822423,
        3201822424,
        3201822425,
        3201822426,
        3201822423
    ],
    "tags": {
        "building": "yes",
        "historic": "tomb",
        "sorting_name": "Panhard",
        "wikidata": "Q266561",
        "wikimedia_commons": "Category:Grave of Panhard (Père-Lachaise, division 36)",
        "wikipedia": "fr:René Panhard"
    }
}

class SyncOpenstreetmapTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_openstreetmap_elements(self):
        openstreetmap_element = OpenstreetmapElement(id="node/123456")
        openstreetmap_element.save()
        sync_openstreetmap.delete_objects()
        self.assertEqual(OpenstreetmapElement.objects.all().count(), 0)

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

    # get_or_create_openstreetmap_element

    def test_get_or_create_openstreetmap_element_creates_object_if_it_does_not_exist(self):
        overpass_element = OVERPASS_ELEMENT_1
        openstreetmap_element, created = sync_openstreetmap.get_or_create_openstreetmap_element(overpass_element)
        self.assertEqual(OpenstreetmapElement.objects.all().count(), 1)
        self.assertIsNotNone(openstreetmap_element)
        self.assertTrue(created)

    def test_get_or_create_openstreetmap_element_does_not_create_duplicate_object_if_it_exists(self):
        openstreetmap_element = OpenstreetmapElement(id="node/2765555563")
        openstreetmap_element.save()
        overpass_element = OVERPASS_ELEMENT_1
        openstreetmap_element, created = sync_openstreetmap.get_or_create_openstreetmap_element(overpass_element)
        self.assertEqual(OpenstreetmapElement.objects.all().count(), 1)
        self.assertIsNotNone(openstreetmap_element)
        self.assertFalse(created)

    def test_get_or_create_openstreetmap_element_does_not_create_object_if_it_is_excluded(self):
        overpass_element = OVERPASS_ELEMENT_1
        openstreetmap_element, created = sync_openstreetmap.get_or_create_openstreetmap_element(overpass_element, ["node/2765555563"])
        self.assertEqual(OpenstreetmapElement.objects.all().count(), 0)
        self.assertIsNone(openstreetmap_element)
        self.assertFalse(created)

    def test_get_or_create_openstreetmap_element_updates_fields(self):
        overpass_element = OVERPASS_ELEMENT_1
        openstreetmap_element, created = sync_openstreetmap.get_or_create_openstreetmap_element(overpass_element)
        self.assertEqual(openstreetmap_element.id, "node/2765555563")
        self.assertEqual(openstreetmap_element.name, "Étienne Lamy")
        self.assertEqual(openstreetmap_element.latitude, 48.8618534)
        self.assertEqual(openstreetmap_element.longitude, 2.3934719)
        self.assertEqual(openstreetmap_element.tags(), overpass_element["tags"])

    def test_get_or_create_openstreetmap_element_updates_name_without_name(self):
        overpass_element = OVERPASS_ELEMENT_2
        openstreetmap_element, created = sync_openstreetmap.get_or_create_openstreetmap_element(overpass_element)
        self.assertEqual(openstreetmap_element.name, "")

    def test_get_or_create_openstreetmap_element_updates_coordinate_without_center(self):
        overpass_element = OVERPASS_ELEMENT_1
        openstreetmap_element, created = sync_openstreetmap.get_or_create_openstreetmap_element(overpass_element)
        self.assertEqual(openstreetmap_element.latitude, 48.8618534)
        self.assertEqual(openstreetmap_element.longitude, 2.3934719)

    def test_get_or_create_openstreetmap_element_updates_coordinate_with_center(self):
        overpass_element = OVERPASS_ELEMENT_2
        openstreetmap_element, created = sync_openstreetmap.get_or_create_openstreetmap_element(overpass_element)
        self.assertEqual(openstreetmap_element.latitude, 48.8583882)
        self.assertEqual(openstreetmap_element.longitude, 2.3956719)

    # update_model

    def test_update_model_returns_openstreetmap_elements_for_overpass_elements(self):
        overpass_elements = [OVERPASS_ELEMENT_1, OVERPASS_ELEMENT_2]
        openstreetmap_elements, created = sync_openstreetmap.update_model(overpass_elements)
        self.assertEqual([openstreetmap_element.id for openstreetmap_element in openstreetmap_elements], ["node/2765555563", "way/314136876"])

    def test_update_model_increments_created_if_openstreetmap_element_was_created(self):
        openstreetmap_element_1 = OpenstreetmapElement(id="node/2765555563")
        openstreetmap_element_1.save()
        overpass_elements = [OVERPASS_ELEMENT_1, OVERPASS_ELEMENT_2]
        openstreetmap_elements, created = sync_openstreetmap.update_model(overpass_elements)
        self.assertEqual(created, 1)
