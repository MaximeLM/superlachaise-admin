import json
from django.test import TestCase
from django.core.exceptions import ValidationError

from superlachaise.models import *

class CommonsCategoryTestCase(TestCase):

    # validation

    def test_validation_succeeds_if_id_is_not_none(self):
        commons_category = CommonsCategory(id="Jim Morrison")
        commons_category.full_clean()

    def test_validation_fails_if_id_is_none(self):
        commons_category = CommonsCategory(id=None)
        with self.assertRaises(ValidationError):
            commons_category.full_clean()

    # commons_url

    def test_commons_url_returns_commons_url_format_if_id_is_valid(self):
        commons_category = CommonsCategory(id="Jim Morrison")
        self.assertEqual(commons_category.commons_url(), CommonsCategory.COMMONS_URL_FORMAT.format(id="Jim Morrison"))

    def test_commons_url_returns_none_if_id_is_none(self):
        commons_category = CommonsCategory(id=None)
        self.assertIsNone(commons_category.commons_url())
