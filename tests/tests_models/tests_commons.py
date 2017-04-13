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

    # redirect

    def test_redirect_is_set_to_none_if_redirect_is_deleted(self):
        commons_category = CommonsCategory(id="Jim Morrison (old)", redirect=CommonsCategory(id="Jim Morrison"))
        commons_category.save()
        self.assertIsNotNone(commons_category.redirect)
        commons_category.redirect.delete()
        commons_category = CommonsCategory.objects.get(id="Jim Morrison (old)")
        self.assertIsNone(commons_category.redirect)

    # main_commons_file

    def test_main_commons_file_is_set_to_none_if_main_commons_image_is_deleted(self):
        commons_category = CommonsCategory(id="Jim Morrison (category)", main_commons_file=CommonsFile(id="Jim Morrison"))
        commons_category.save()
        self.assertIsNotNone(commons_category.main_commons_file)
        commons_category.main_commons_file.delete()
        commons_category = CommonsCategory.objects.get(id="Jim Morrison (category)")
        self.assertIsNone(commons_category.main_commons_file)

    # commons_files

    def test_commons_file_is_removed_from_commons_files_if_deleted(self):
        commons_category = CommonsCategory(id="Jim Morrison (category)")
        commons_file = CommonsFile(id="Jim Morrison")
        commons_category.commons_files.add(commons_file)
        commons_file.save()
        commons_category.save()
        self.assertEqual(commons_category.commons_files.count(), 1)
        commons_file.delete()
        commons_category = CommonsCategory.objects.get(id="Jim Morrison (category)")
        self.assertEqual(commons_category.commons_files.count(), 0)

    def test_commons_file_is_not_deleted_if_commons_category_is_deleted(self):
        commons_category = CommonsCategory(id="Jim Morrison (category)")
        commons_file = CommonsFile(id="Jim Morrison")
        commons_category.commons_files.add(commons_file)
        commons_file.save()
        commons_category.save()
        self.assertEqual(CommonsFile.objects.filter(id="Jim Morrison").count(), 1)
        commons_category.delete()
        self.assertEqual(CommonsFile.objects.filter(id="Jim Morrison").count(), 1)

class CommonsFileTestCase(TestCase):

    # validation

    def test_validation_succeeds_if_id_is_not_none(self):
        commons_file = CommonsFile(id="Jim Morrison")
        commons_file.full_clean()

    def test_validation_fails_if_id_is_none(self):
        commons_file = CommonsFile(id=None)
        with self.assertRaises(ValidationError):
            commons_file.full_clean()

    # commons_url

    def test_commons_url_returns_commons_url_format_if_id_is_valid(self):
        commons_file = CommonsFile(id="Jim Morrison")
        self.assertEqual(commons_file.commons_url(), CommonsFile.COMMONS_URL_FORMAT.format(id="Jim Morrison"))

    def test_commons_url_returns_none_if_id_is_none(self):
        commons_file = CommonsFile(id=None)
        self.assertIsNone(commons_file.commons_url())
