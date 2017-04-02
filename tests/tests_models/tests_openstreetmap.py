import json
from json.decoder import JSONDecodeError
from django.test import TestCase
from django.core.exceptions import ValidationError

from superlachaise.models import *

# Fixtures

def OPENSTREETMAP_ELEMENT_1():
    return OpenStreetMapElement(
        id="node/2765555563",
        raw_tags=json.dumps({
            "historic": "tomb",
            "name": "Étienne Lamy",
            "sorting_name": "Lamy",
            "wikidata": "Q1218474",
            "name:wikidata": "Q123456",
            "wikimedia_commons": "Category:Grave of Lamy (Père-Lachaise, division 49)",
            "wikipedia": "fr:Étienne Lamy"
        })
    )

def OPENSTREETMAP_ELEMENT_2():
    return OpenStreetMapElement(
        id="way/314136876",
        raw_tags=json.dumps({
            "building": "yes",
            "historic": "tomb",
            "sorting_name": "Panhard",
            "name:wikidata": "Q266561",
            "wikimedia_commons": "Category:Grave of Panhard (Père-Lachaise, division 36)",
            "wikipedia": "fr:René Panhard"
        })
    )

class OpenStreetMapElementTestCase(TestCase):

    # validation

    def test_validation_succeeds_if_id_has_slash(self):
        openstreetmap_element = OpenStreetMapElement(id="node/123456")
        openstreetmap_element.full_clean()

    def test_validation_fails_if_id_has_no_slash(self):
        openstreetmap_element = OpenStreetMapElement(id="123456")
        with self.assertRaises(ValidationError):
            openstreetmap_element.full_clean()

    def test_validation_fails_if_id_is_none(self):
        openstreetmap_element = OpenStreetMapElement(id=None)
        with self.assertRaises(ValidationError):
            openstreetmap_element.full_clean()

    def test_validation_succeeds_if_name_is_blank(self):
        openstreetmap_element = OpenStreetMapElement(id="node/123456", name="")
        openstreetmap_element.full_clean()

    def test_validation_fails_if_latitude_is_none(self):
        openstreetmap_element = OpenStreetMapElement(
            id="node/123456",
            latitude=None)
        with self.assertRaises(ValidationError):
            openstreetmap_element.full_clean()

    def test_validation_fails_if_longitude_is_none(self):
        openstreetmap_element = OpenStreetMapElement(
            id="node/123456",
            longitude=None)
        with self.assertRaises(ValidationError):
            openstreetmap_element.full_clean()

    def test_validation_succeeds_if_raw_tags_is_valid_JSON(self):
        openstreetmap_element = OpenStreetMapElement(
            id="node/123456",
            raw_tags=json.dumps({"key": "value"}))
        openstreetmap_element.full_clean()

    def test_validation_fails_if_raw_tags_is_none(self):
        openstreetmap_element = OpenStreetMapElement(
            id="node/123456",
            raw_tags=None)
        with self.assertRaises(ValidationError):
            openstreetmap_element.full_clean()

    def test_validation_fails_if_raw_tags_is_invalid_JSON(self):
        openstreetmap_element = OpenStreetMapElement(
            id="node/123456",
            raw_tags="tags")
        with self.assertRaises(ValidationError):
            openstreetmap_element.full_clean()

    # tags

    def test_tags_returns_object_if_raw_tags_is_valid_JSON(self):
        object = {"key": "value"}
        openstreetmap_element = OpenStreetMapElement(
            raw_tags=json.dumps(object))
        self.assertEqual(openstreetmap_element.tags(), object)

    def test_tags_returns_none_if_raw_tags_is_none(self):
        openstreetmap_element = OpenStreetMapElement(
            raw_tags=None)
        self.assertIsNone(openstreetmap_element.tags())

    def test_tags_fails_if_raw_tags_is_invalid_JSON(self):
        openstreetmap_element = OpenStreetMapElement(
            raw_tags="tags")
        with self.assertRaises(JSONDecodeError):
            openstreetmap_element.tags()

    # openstreetmap_url

    def test_openstreetmap_url_returns_openstreetmap_url_format_if_id_is_not_none(self):
        id = "node/123456"
        openstreetmap_element = OpenStreetMapElement(id=id)
        self.assertEqual(OpenStreetMapElement.OPENSTREETMAP_URL_FORMAT.format(id=id), openstreetmap_element.openstreetmap_url())

    def test_openstreetmap_url_returns_none_if_id_is_none(self):
        openstreetmap_element = OpenStreetMapElement(id=None)
        self.assertIsNone(openstreetmap_element.openstreetmap_url())

    # get_first_tag_value

    def test_get_first_tag_value_returns_first_tag_value_if_present(self):
        wikidata_id = OPENSTREETMAP_ELEMENT_1().get_first_tag_value(
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual(wikidata_id, "Q1218474")

    def test_get_first_tag_value_returns_next_tag_value_if_present_and_first_tag_is_not_present(self):
        wikidata_id = OPENSTREETMAP_ELEMENT_2().get_first_tag_value(
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual(wikidata_id, "Q266561")

    def test_get_first_tag_value_returns_none_if_no_tag_is_present(self):
        wikidata_id = OPENSTREETMAP_ELEMENT_1().get_first_tag_value(
            ["myTag", "myOtherTag:wikidata"]
        )
        self.assertIsNone(wikidata_id)
