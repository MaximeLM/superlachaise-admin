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

def WIKIDATA_ENTRY_2():
    return WikidataEntry(
        id="Q11984907",
        raw_sitelinks=json.dumps({
            "frwiki": {
                "site": "frwiki",
                "title": "Émile Oberkampf",
                "badges": []
            }
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

    def test_get_or_create_wikipedia_pages_from_wikidata_entries_returns_wikipedia_pages_by_language_for_languages_wiki_sites(self):
        wikidata_entry_1 = WIKIDATA_ENTRY_1()
        wikidata_entry_1.save()
        wikidata_entry_2 = WIKIDATA_ENTRY_2()
        wikidata_entry_2.save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_from_wikidata_entries([wikidata_entry_1, wikidata_entry_2], ["fr", "en"])
        self.assertEqual(set(wikipedia_pages.keys()), set(["fr", "en"]))
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages["fr"]], ["fr|Charles-Joseph Panckoucke (fr)", "fr|Émile Oberkampf"])
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages["en"]], ["en|Charles-Joseph Panckoucke (en)"])

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

    def test_get_or_create_wikipedia_pages_to_refresh_returns_wikipedia_pages_by_language_for_all_wikidata_entries_if_ids_is_none(self):
        WIKIDATA_ENTRY_1().save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(None, ["fr", "en"])
        self.assertEqual(set(wikipedia_pages.keys()), set(["fr", "en"]))
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages["fr"]], ["fr|Charles-Joseph Panckoucke (fr)"])
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages["en"]], ["en|Charles-Joseph Panckoucke (en)"])

    def test_get_or_create_wikipedia_pages_to_refresh_returns_created_wikipedia_pages_if_ids_is_none(self):
        WIKIDATA_ENTRY_1().save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(None, ["fr", "en"])
        self.assertEqual(created, 2)

    def test_get_or_create_wikipedia_pages_to_refresh_returns_wikipedia_pages_for_ids_if_ids_is_not_none(self):
        ids = ["fr|Charles-Joseph Panckoucke (fr)", "en|Charles-Joseph Panckoucke (en)"]
        for id in ids:
            WikipediaPage(id=id).save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(ids, ["fr", "en"])
        self.assertEqual(set(wikipedia_pages.keys()), set(["fr", "en"]))
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages["fr"]], ["fr|Charles-Joseph Panckoucke (fr)"])
        self.assertEqual([wikipedia_page.id for wikipedia_page in wikipedia_pages["en"]], ["en|Charles-Joseph Panckoucke (en)"])

    def test_get_or_create_wikipedia_pages_to_refresh_returns_0_created_if_ids_is_not_none(self):
        ids = ["fr|Charles-Joseph Panckoucke (fr)", "en|Charles-Joseph Panckoucke (en)"]
        for id in ids:
            WikipediaPage(id=id).save()
        wikipedia_pages, created = sync_wikipedia_pages.get_or_create_wikipedia_pages_to_refresh(ids, ["fr", "en"])
        self.assertEqual(created, 0)

    # make_chunks

    def test_make_chunks_returns_ordered_elements_in_max_size_chunks(self):
        wikipedia_pages = [
            WikipediaPage(id="fr|Jim_1"),
            WikipediaPage(id="fr|Jim_2"),
            WikipediaPage(id="fr|Jim_3"),
            WikipediaPage(id="fr|Jim_4"),
            WikipediaPage(id="fr|Jim_5"),
        ]
        self.assertEqual(sync_wikipedia_pages.make_chunks(wikipedia_pages, 2), [
            [wikipedia_pages[0], wikipedia_pages[1]],
            [wikipedia_pages[2], wikipedia_pages[3]],
            [wikipedia_pages[4]],
        ])

    # make_wikipedia_query_params

    def test_make_wikipedia_query_params_returns_titles_key_with_wikipedia_pages_titles_separated_by_pipes(self):
        wikipedia_pages = [
            WikipediaPage(id="fr|Jim_1"),
            WikipediaPage(id="fr|Jim_2"),
        ]
        params = sync_wikipedia_pages.make_wikipedia_query_params(wikipedia_pages)
        self.assertEqual(params["titles"], "Jim_1|Jim_2")
