import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

# Fixtures

class SyncCommonsCategoriesTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_commons_categories(self):
        commons_category = CommonsCategory(id="Jim Morrison")
        commons_category.save()
        sync_commons_categories.delete_objects()
        self.assertEqual(CommonsCategory.objects.all().count(), 0)

    # get_or_create_commons_categories_from_wikidata_entries

    def test_get_or_create_commons_categories_from_wikidata_entries_returns_commons_categories_for_wikidata_entries(self):
        def get_commons_category_id(wikidata_entry):
            return wikidata_entry.id+" (category)"
        wikidata_entry_1 = WikidataEntry(id="Q123456")
        wikidata_entry_1.save()
        wikidata_entry_2 = WikidataEntry(id="Q654321")
        wikidata_entry_2.save()
        commons_categories, created = sync_commons_categories.get_or_create_commons_categories_from_wikidata_entries([wikidata_entry_1, wikidata_entry_2], get_commons_category_id)
        self.assertEqual([commons_category.id for commons_category in commons_categories], ["Q123456 (category)", "Q654321 (category)"])

    def test_get_or_create_commons_categories_from_wikidata_entries_increments_created_if_commons_category_was_created(self):
        def get_commons_category_id(wikidata_entry):
            return wikidata_entry.id+" (category)"
        wikidata_entry_1 = WikidataEntry(id="Q123456")
        wikidata_entry_1.save()
        wikidata_entry_2 = WikidataEntry(id="Q654321")
        wikidata_entry_2.save()
        CommonsCategory(id="Q123456 (category)").save()
        commons_categories, created = sync_commons_categories.get_or_create_commons_categories_from_wikidata_entries([wikidata_entry_1, wikidata_entry_2], get_commons_category_id)
        self.assertEqual(created, 1)

    def test_get_or_create_commons_categories_from_wikidata_entries_sets_commons_category_relation_if_found(self):
        def get_commons_category_id(wikidata_entry):
            return wikidata_entry.id+" (category)"
        wikidata_entry = WikidataEntry(id="Q123456")
        wikidata_entry.save()
        sync_commons_categories.get_or_create_commons_categories_from_wikidata_entries([wikidata_entry], get_commons_category_id)
        self.assertEqual(wikidata_entry.commons_category.id, "Q123456 (category)")

    def test_get_or_create_commons_categories_from_wikidata_entries_sets_commons_category_relation_to_none_if_not_found(self):
        def get_commons_category_id(wikidata_entry):
            return None
        wikidata_entry = WikidataEntry(id="Q123456", commons_category=CommonsCategory(id="Q123456 (category)"))
        wikidata_entry.save()
        self.assertIsNotNone(wikidata_entry.commons_category)
        sync_commons_categories.get_or_create_commons_categories_from_wikidata_entries([wikidata_entry], get_commons_category_id)
        self.assertIsNone(wikidata_entry.commons_category)

    # get_or_create_commons_categories_to_refresh

    def test_get_or_create_commons_categories_to_refresh_returns_commons_categories_for_all_wikidata_entries_if_ids_is_none(self):
        def get_commons_category_id(wikidata_entry):
            return wikidata_entry.id+" (category)"
        WikidataEntry(id="Q123456").save()
        WikidataEntry(id="Q654321").save()
        commons_categories, created = sync_commons_categories.get_or_create_commons_categories_to_refresh(None, get_commons_category_id=get_commons_category_id)
        self.assertEqual([commons_category.id for commons_category in commons_categories], ["Q123456 (category)", "Q654321 (category)"])

    def test_get_or_create_commons_categories_to_refresh_returns_created_commons_categories_if_ids_is_none(self):
        def get_commons_category_id(wikidata_entry):
            return wikidata_entry.id+" (category)"
        WikidataEntry(id="Q123456").save()
        WikidataEntry(id="Q654321").save()
        commons_categories, created = sync_commons_categories.get_or_create_commons_categories_to_refresh(None, get_commons_category_id=get_commons_category_id)
        self.assertEqual(created, 2)

    def test_get_or_create_commons_categories_to_refresh_returns_commons_categories_for_ids_if_ids_is_not_none(self):
        def get_commons_category_id(wikidata_entry):
            return wikidata_entry.id+" (category)"
        ids = ["Q1218474 (category)", "Q266561 (category)"]
        for id in ids:
            CommonsCategory(id=id).save()
        commons_categories, created = sync_commons_categories.get_or_create_commons_categories_to_refresh(ids, get_commons_category_id=get_commons_category_id)
        self.assertEqual(set([commons_category.id for commons_category in commons_categories]), set(ids))

    def test_get_or_create_commons_categories_to_refresh_returns_0_created_if_ids_is_not_none(self):
        def get_commons_category_id(wikidata_entry):
            return wikidata_entry.id+" (category)"
        ids = ["Q1218474 (category)", "Q266561 (category)"]
        for id in ids:
            CommonsCategory(id=id).save()
        commons_categories, created = sync_commons_categories.get_or_create_commons_categories_to_refresh(ids, get_commons_category_id=get_commons_category_id)
        self.assertEqual(created, 0)
