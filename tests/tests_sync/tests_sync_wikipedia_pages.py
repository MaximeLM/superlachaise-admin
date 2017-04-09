import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

# Fixtures

def WIKIDATA_ENTRY_1():
    return WikidataEntry(
        id="Q123456",
        raw_sitelinks=json.dumps({
            "enwiki": {
                "site": "enwiki",
                "title": "Charles-Joseph Panckoucke (en)",
                "badges": []
            },
            "frwiki": {
                "site": "frwiki",
                "title": "Charles-Joseph Panckoucke (fr)",
                "badges": []
            },
        })
    )

class SyncWikipediaPagesTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_wikipedia_pages(self):
        wikipedia_page = WikipediaPage(id="fr|Jim_Morrison")
        wikipedia_page.save()
        sync_wikipedia_pages.delete_objects()
        self.assertEqual(WikipediaPage.objects.all().count(), 0)

    # get_or_create_wikipedia_pages_from_wikidata_entries

    def test_get_or_create_wikipedia_pages_from_wikidata_entries_returns_wikipedia_pages_for_languages_wiki_sites(self):
        wikidata_entry = WIKIDATA_ENTRY_1()
        wikidata_entry.save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_from_wikidata_entries([wikidata_entry], ["fr", "en"])
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages], ["fr|Charles-Joseph Panckoucke (fr)", "en|Charles-Joseph Panckoucke (en)"])

    def test_get_or_create_wikipedia_pages_from_wikidata_entries_increments_created_if_wikipedia_page_was_created(self):
        wikidata_entry = WIKIDATA_ENTRY_1()
        wikidata_entry.save()
        wikipedia_page = WikipediaPage(id="fr|Charles-Joseph Panckoucke (fr)")
        wikipedia_page.save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_from_wikidata_entries([wikidata_entry], ["fr", "en"])
        self.assertEqual(created, 1)

    def test_get_or_create_wikipedia_pages_from_wikidata_entries_sets_wikipedia_pages_relation(self):
        wikidata_entry = WIKIDATA_ENTRY_1()
        wikidata_entry.save()
        sync_wikipedia_pages.get_or_create_wikipedia_pages_from_wikidata_entries([wikidata_entry], ["fr", "en"])
        self.assertEqual(set([wikipedia_page.id for wikipedia_page in wikidata_entry.wikipedia_pages.all()]), set(["fr|Charles-Joseph Panckoucke (fr)", "en|Charles-Joseph Panckoucke (en)"]))

    # get_or_create_wikipedia_pages_to_refresh

    def test_get_or_create_wikipedia_pages_to_refresh_returns_wikipedia_pages_for_all_wikidata_entries_if_ids_is_none(self):
        WIKIDATA_ENTRY_1().save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(None, ["fr", "en"])
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages], ["fr|Charles-Joseph Panckoucke (fr)", "en|Charles-Joseph Panckoucke (en)"])

    def test_get_or_create_wikipedia_pages_to_refresh_returns_created_wikipedia_pages_if_ids_is_none(self):
        WIKIDATA_ENTRY_1().save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(None, ["fr", "en"])
        self.assertEqual(created, 2)

    def test_get_or_create_wikipedia_pages_to_refresh_returns_wikipedia_pages_for_ids_if_ids_is_not_none(self):
        ids = ["fr|Charles-Joseph Panckoucke (fr)", "en|Charles-Joseph Panckoucke (en)"]
        for id in ids:
            WikipediaPage(id=id).save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(ids, ["fr", "en"])
        self.assertEqual(set([wikipedia_page.id for wikipedia_page in wikipedia_pages]), set(ids))

    def test_get_or_create_wikipedia_pages_to_refresh_returns_0_created_if_ids_is_not_none(self):
        ids = ["fr|Charles-Joseph Panckoucke (fr)", "en|Charles-Joseph Panckoucke (en)"]
        for id in ids:
            WikipediaPage(id=id).save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(ids, ["fr", "en"])
        self.assertEqual(created, 0)
