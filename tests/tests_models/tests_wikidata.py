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

    def test_validation_succeeds_if_raw_labels_is_valid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_labels=json.dumps({"key": "value"}))
        wikidata_entry.full_clean()

    def test_validation_fails_if_raw_labels_is_none(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_labels=None)
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_fails_if_raw_labels_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_labels="json")
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_succeeds_if_raw_descriptions_is_valid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_descriptions=json.dumps({"key": "value"}))
        wikidata_entry.full_clean()

    def test_validation_fails_if_raw_descriptions_is_none(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_descriptions=None)
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_fails_if_raw_descriptions_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_descriptions="json")
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_succeeds_if_raw_claims_is_valid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_claims=json.dumps({"key": "value"}))
        wikidata_entry.full_clean()

    def test_validation_fails_if_raw_claims_is_none(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_claims=None)
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_fails_if_raw_claims_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_claims="json")
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_succeeds_if_raw_sitelinks_is_valid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_sitelinks=json.dumps({"key": "value"}))
        wikidata_entry.full_clean()

    def test_validation_fails_if_raw_sitelinks_is_none(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_sitelinks=None)
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    def test_validation_fails_if_raw_sitelinks_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            id="Q123456",
            raw_sitelinks="json")
        with self.assertRaises(ValidationError):
            wikidata_entry.full_clean()

    # labels

    def test_labels_returns_object_if_raw_labels_is_valid_JSON(self):
        object = {"key": "value"}
        wikidata_entry = WikidataEntry(
            raw_labels=json.dumps(object))
        self.assertEqual(wikidata_entry.labels(), object)

    def test_labels_returns_none_if_raw_labels_is_none(self):
        wikidata_entry = WikidataEntry(
            raw_labels=None)
        self.assertIsNone(wikidata_entry.labels())

    def test_labels_fails_if_raw_labels_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            raw_labels="json")
        with self.assertRaises(JSONDecodeError):
            wikidata_entry.labels()

    # descriptions

    def test_descriptions_returns_object_if_raw_descriptions_is_valid_JSON(self):
        object = {"key": "value"}
        wikidata_entry = WikidataEntry(
            raw_descriptions=json.dumps(object))
        self.assertEqual(wikidata_entry.descriptions(), object)

    def test_descriptions_returns_none_if_raw_descriptions_is_none(self):
        wikidata_entry = WikidataEntry(
            raw_descriptions=None)
        self.assertIsNone(wikidata_entry.descriptions())

    def test_descriptions_fails_if_raw_descriptions_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            raw_descriptions="json")
        with self.assertRaises(JSONDecodeError):
            wikidata_entry.descriptions()

    # claims

    def test_claims_returns_object_if_raw_claims_is_valid_JSON(self):
        object = {"key": "value"}
        wikidata_entry = WikidataEntry(
            raw_claims=json.dumps(object))
        self.assertEqual(wikidata_entry.claims(), object)

    def test_claims_returns_none_if_raw_claims_is_none(self):
        wikidata_entry = WikidataEntry(
            raw_claims=None)
        self.assertIsNone(wikidata_entry.claims())

    def test_claims_fails_if_raw_claims_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            raw_claims="json")
        with self.assertRaises(JSONDecodeError):
            wikidata_entry.claims()

    # sitelinks

    def test_sitelinks_returns_object_if_raw_sitelinks_is_valid_JSON(self):
        object = {"key": "value"}
        wikidata_entry = WikidataEntry(
            raw_sitelinks=json.dumps(object))
        self.assertEqual(wikidata_entry.sitelinks(), object)

    def test_sitelinks_returns_none_if_raw_sitelinks_is_none(self):
        wikidata_entry = WikidataEntry(
            raw_sitelinks=None)
        self.assertIsNone(wikidata_entry.sitelinks())

    def test_sitelinks_fails_if_raw_sitelinks_is_invalid_JSON(self):
        wikidata_entry = WikidataEntry(
            raw_sitelinks="json")
        with self.assertRaises(JSONDecodeError):
            wikidata_entry.sitelinks()

    # wikidata_url

    def test_wikidata_url_returns_wikidata_url_format_if_id_is_not_none(self):
        id = "Q123456"
        wikidata_entry = WikidataEntry(id=id)
        self.assertEqual(WikidataEntry.WIKIDATA_URL_FORMAT.format(id=id), wikidata_entry.wikidata_url())

    def test_wikidata_url_returns_none_if_id_is_none(self):
        wikidata_entry = WikidataEntry(id=None)
        self.assertIsNone(wikidata_entry.wikidata_url())

    # get_first_label

    def test_get_first_label_returns_first_label_if_it_exists(self):
        wikidata_entry = WikidataEntry(raw_labels=json.dumps(
            {
                "en": {
                    "language": "en",
                    "value": "Annie Girardot (en)"
                },
                "fr": {
                    "language": "fr",
                    "value": "Annie Girardot (fr)"
                }
            }
        ))
        self.assertEqual(wikidata_entry.get_first_label(), "Annie Girardot (en)")

    def test_get_first_label_returns_none_if_no_label_exists(self):
        wikidata_entry = WikidataEntry()
        self.assertIsNone(wikidata_entry.get_first_label())

    # get_label

    def test_get_label_returns_label_for_language_if_it_exists(self):
        wikidata_entry = WikidataEntry(raw_labels=json.dumps(
            {
                "en": {
                    "language": "en",
                    "value": "Annie Girardot (en)"
                },
                "fr": {
                    "language": "fr",
                    "value": "Annie Girardot (fr)"
                }
            }
        ))
        self.assertEqual(wikidata_entry.get_label("en"), "Annie Girardot (en)")

    def test_get_label_returns_none_for_language_if_it_does_not_exist(self):
        wikidata_entry = WikidataEntry(raw_labels=json.dumps(
            {
                "en": {
                    "language": "en",
                    "value": "Annie Girardot (fr)"
                },
                "fr": {
                    "language": "fr",
                    "value": "Annie Girardot (en)"
                }
            }
        ))
        self.assertIsNone(wikidata_entry.get_label("de"))

    # get_description

    def test_get_description_returns_description_for_language_if_it_exists(self):
        wikidata_entry = WikidataEntry(raw_descriptions=json.dumps(
            {
                "fr": {
                    "language": "fr",
                    "value": "actrice française"
                },
                "en": {
                    "language": "en",
                    "value": "French actress"
                }
            }
        ))
        self.assertEqual(wikidata_entry.get_description("en"), "French actress")

    def test_get_description_returns_none_for_language_if_it_does_not_exist(self):
        wikidata_entry = WikidataEntry(raw_descriptions=json.dumps(
            {
                "fr": {
                    "language": "fr",
                    "value": "actrice française"
                },
                "en": {
                    "language": "en",
                    "value": "French actress"
                }
            }
        ))
        self.assertIsNone(wikidata_entry.get_description("de"))
