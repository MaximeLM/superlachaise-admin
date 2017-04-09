import json
from json.decoder import JSONDecodeError
from django.test import TestCase
from django.core.exceptions import ValidationError

from superlachaise.models import *

class WikipediaPageTestCase(TestCase):

    # validation

    def test_validation_succeeds_if_id_has_valid_format(self):
        wikipedia_page = WikipediaPage(id="fr|Jim_Morrison")
        wikipedia_page.full_clean()

    def test_validation_fails_if_id_has_invalid_format(self):
        wikipedia_page = WikipediaPage(id="123456")
        with self.assertRaises(ValidationError):
            wikipedia_page.full_clean()

    def test_validation_fails_if_id_is_none(self):
        wikipedia_page = WikipediaPage(id=None)
        with self.assertRaises(ValidationError):
            wikipedia_page.full_clean()

    # id_parts

    def test_id_parts_returns_language_and_title_if_id_is_valid(self):
        wikipedia_page = WikipediaPage(id="fr|Jim_Morrison")
        self.assertEqual(wikipedia_page.id_parts(), ("fr", "Jim_Morrison"))

    def test_id_parts_returns_none_tuple_if_id_is_invalid(self):
        wikipedia_page = WikipediaPage(id="123456")
        self.assertEqual(wikipedia_page.id_parts(), (None, None))

    # wikipedia_url

    def test_wikipedia_url_returns_openstreetmap_url_format_if_id_is_valid(self):
        wikipedia_page = WikipediaPage(id="fr|Jim_Morrison")
        self.assertEqual(wikipedia_page.wikipedia_url(), WikipediaPage.WIKIPEDIA_URL_FORMAT.format(language="fr", title="Jim_Morrison"))

    def test_wikipedia_url_returns_none_if_id_is_none(self):
        wikipedia_page = WikipediaPage(id="123456")
        self.assertIsNone(wikipedia_page.wikipedia_url())
