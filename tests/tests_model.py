import json
from django.test import TestCase
from django.core.exceptions import ValidationError

from superlachaise.models import *

class OpenStreetMapElementTestCase(TestCase):

    # validation

    def test_validation_succeeds_if_id_is_not_none(self):
        openstreetmap_element = OpenStreetMapElement(id="node/123456")
        openstreetmap_element.full_clean()

    def test_validation_fails_if_id_is_none(self):
        openstreetmap_element = OpenStreetMapElement(id=None)
        with self.assertRaises(ValidationError):
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

    def test_tags_returns_none_if_raw_tags_is_invalid_JSON(self):
        openstreetmap_element = OpenStreetMapElement(
            raw_tags="tags")
        self.assertIsNone(openstreetmap_element.tags())

    # openstreetmap_url

    def test_openstreetmap_url_returns_openstreetmap_url_format_if_id_is_not_none(self):
        id = "node/123456"
        openstreetmap_element = OpenStreetMapElement(id=id)
        self.assertEqual(OpenStreetMapElement.URL_FORMAT.format(id=id), openstreetmap_element.openstreetmap_url())

    def test_openstreetmap_url_returns_none_if_id_is_none(self):
        openstreetmap_element = OpenStreetMapElement(id=None)
        self.assertIsNone(openstreetmap_element.openstreetmap_url())
