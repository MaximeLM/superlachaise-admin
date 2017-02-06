import json
from json.decoder import JSONDecodeError
from django.test import TestCase
from django.core.exceptions import ValidationError

from superlachaise.models import *

class WikidataEntryTestCase(TestCase):

    # validation

    def test_validation_succeeds_if_id_has_valid_format(self):
        wikidata_entry = WikidataEntry(id="Q123456")
        wikidata_entry.full_clean()

    def test_validation_fails_if_id_has_invalid_format(self):
        wikidata_entry = WikidataEntry(id="123456")
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_fails_if_id_is_none(self):
        wikidata_entry = WikidataEntry(id=None)
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_succeeds_if_raw_json_is_valid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_json=json.dumps({"key": "value"}))
        wikidata_entry.full_clean()

    def test_validation_fails_if_raw_json_is_none(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_json=None)
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_fails_if_raw_json_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_json="json")
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    # json

    def test_json_returns_object_if_raw_json_is_valid_JSON(self):
        object = {"key": "value"}
        wikidata_entry = WikidataEntry(
            raw_json=json.dumps(object))
        self.assertEqual(wikidata_entry.json(), object)

    def test_json_returns_none_if_raw_json_is_none(self):
        wikidata_entry = WikidataEntry(
            raw_json=None)
        self.assertIsNone(wikidata_entry.json())

    def test_json_fails_if_raw_json_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            raw_json="json")
        with self.assertRaises(JSONDecodeError):
            wikidata_entry.json()

    # wikidata_url

    def test_wikidata_url_returns_wikidata_url_format_if_id_is_not_none(self):
        id = "Q123456"
        wikidata_entry = WikidataEntry(id=id)
        self.assertEqual(WikidataEntry.WIKIDATA_URL_FORMAT.format(id=id), wikidata_entry.wikidata_url())

    def test_wikidata_url_returns_none_if_id_is_none(self):
        wikidata_entry = WikidataEntry(id=None)
        self.assertIsNone(wikidata_entry.wikidata_url())
