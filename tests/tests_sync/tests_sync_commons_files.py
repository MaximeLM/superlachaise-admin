import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

class SyncCommonsFilesTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_commons_files(self):
        commons_file = CommonsFile(id="Jim Morrison")
        commons_file.save()
        sync_commons_files.delete_objects()
        self.assertEqual(CommonsFile.objects.all().count(), 0)

    # get_or_create_main_commons_files_from_commons_categories

    def test_get_or_create_main_commons_files_from_commons_categories_returns_main_commons_files_from_commons_categories_images(self):
        commons_category_1 = CommonsCategory(id="Category 1", image="Image 1")
        commons_category_1.save()
        commons_category_2 = CommonsCategory(id="Category 2", image="Image 2")
        commons_category_2.save()
        commons_files, created = sync_commons_files.get_or_create_main_commons_files_from_commons_categories([commons_category_1, commons_category_2])
        self.assertEqual([commons_file.id for commons_file in commons_files], ["Image 1", "Image 2"])

    def test_get_or_create_main_commons_files_from_commons_categories_increments_created_if_commons_file_was_created(self):
        commons_category_1 = CommonsCategory(id="Category 1", image="Image 1")
        commons_category_1.save()
        commons_category_2 = CommonsCategory(id="Category 2", image="Image 2")
        commons_category_2.save()
        CommonsFile(id="Image 1").save()
        commons_files, created = sync_commons_files.get_or_create_main_commons_files_from_commons_categories([commons_category_1, commons_category_2])
        self.assertEqual(created, 1)

    def test_get_or_create_main_commons_files_from_commons_categories_sets_main_commons_file_relation_if_found(self):
        commons_category = CommonsCategory(id="Category 1", image="Image 1")
        commons_category.save()
        sync_commons_files.get_or_create_main_commons_files_from_commons_categories([commons_category])
        self.assertEqual(commons_category.main_commons_file.id, "Image 1")

    def test_get_or_create_main_commons_files_from_commons_categories_sets_main_commons_file_relation_to_none_if_not_found(self):
        commons_category = CommonsCategory(id="Category 1", main_commons_file=CommonsFile(id="Image 1"))
        commons_category.save()
        self.assertIsNotNone(commons_category.main_commons_file)
        sync_commons_files.get_or_create_main_commons_files_from_commons_categories([commons_category])
        self.assertIsNone(commons_category.main_commons_file)

    # make_category_members_query_params

    def test_make_category_members_query_params_returns_cmtitle_key_with_commons_category_title_prefixed_by_category(self):
        commons_category = CommonsCategory(id="Jim_1")
        params = sync_commons_files.make_category_members_query_params(commons_category)
        self.assertEqual(params["cmtitle"], "Category:Jim_1")
