import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *
from superlachaise.sync.sync_wikipedia_pages import WikipediaAPIError, WikipediaAPIMissingPagesError

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

def WIKIPEDIA_API_RESULT_REVISIONS():
    return {
        "batchcomplete":"",
        "query": {
            "pages": {
                "6998361": {
                    'pageid': 6998361,
                    'ns': 0,
                    'title': 'Jacques-Henri Bernardin de Saint-Pierre',
                    'revisions': [{
                        'contentformat': 'text/x-wiki',
                        'contentmodel': 'wikitext',
                        '*': "'''Jacques-Henri Bernardin de Saint-Pierre''' (also called '''Bernardin de St. Pierre''') (19 January 1737 [[Le Havre]]  &ndash; 21 January 1814 [[Éragny, Val-d'Oise|Éragny]], [[Val-d'Oise]]) was a [[France|French]] writer and [[botanist]]. He is best known for his 1788 novel ''[[Paul et Virginie]]'', now largely forgotten, but in the 19th century a very popular [[children's book]].\n\n{{DEFAULTSORT:    Bernardin de Saint-Pierre, Jacques-Henri}}\n[[Category:École des Ponts ParisTech alumni]]\n"
                    }]
                }
            }
        }
    }

WIKIPEDIA_API_RESULT_MISSING = {
    "batchcomplete":"",
    "query": {
        "pages": {
            "-1": {
                'ns': 0,
                'title': "Oscar Wilde's tomb",
                'missing': ""
            }
        }
    }
}

WIKIPEDIA_API_RESULT_ERROR = {
   "error":{
       "code":"unknown_action",
       "info":"Unrecognized value for parameter \"action\": queryy.",
       "*":"See https://fr.wikipedia.org/w/api.php for API usage. Subscribe to the mediawiki-api-announce mailing list at &lt;https://lists.wikimedia.org/mailman/listinfo/mediawiki-api-announce&gt; for notice of API deprecations and breaking changes."
   },
   "servedby":"mw1197"
}

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

    # make_wikipedia_query_params

    def test_make_wikipedia_query_params_returns_titles_key_with_wikipedia_pages_titles_separated_by_pipes(self):
        wikipedia_pages = [
            WikipediaPage(id="fr|Jim_1"),
            WikipediaPage(id="fr|Jim_2"),
        ]
        params = sync_wikipedia_pages.make_wikipedia_query_params(wikipedia_pages)
        self.assertEqual(params["titles"], "Jim_1|Jim_2")

    # handle_wikipedia_api_result

    def test_handle_wikipedia_api_result_raises_missing_pages_error_for_wikipedia_pages_not_in_result(self):
        wikipedia_page_1 = WikipediaPage(id="fr|Jim_Morrison")
        wikipedia_page_2 = WikipediaPage(id="fr|Jacques-Henri Bernardin de Saint-Pierre")
        try:
            sync_wikipedia_pages.handle_wikipedia_api_result(WIKIPEDIA_API_RESULT_REVISIONS(), [wikipedia_page_1, wikipedia_page_2])
        except WikipediaAPIMissingPagesError as error:
            self.assertEqual([wikipedia_page.id for wikipedia_page in error.wikipedia_pages], ["fr|Jim_Morrison"])
            return
        self.assertTrue(False)

    def test_handle_wikipedia_api_result_raises_missing_pages_error_with_missing_wikipedia_page(self):
        wikipedia_page_1 = WikipediaPage(id="en|Jim_Morrison")
        wikipedia_page_2 = WikipediaPage(id="en|Oscar Wilde's tomb")
        try:
            sync_wikipedia_pages.handle_wikipedia_api_result(WIKIPEDIA_API_RESULT_MISSING, [wikipedia_page_1, wikipedia_page_2])
        except WikipediaAPIMissingPagesError as error:
            self.assertEqual([wikipedia_page.id for wikipedia_page in error.wikipedia_pages], ["en|Oscar Wilde's tomb"])
            return
        self.assertTrue(False)

    def test_handle_wikipedia_api_result_raises_wikipedia_errors_with_error_info(self):
        wikipedia_page = WikipediaPage(id="en|Jim_Morrison")
        try:
            sync_wikipedia_pages.handle_wikipedia_api_result(WIKIPEDIA_API_RESULT_ERROR, [wikipedia_page])
        except WikipediaAPIError as error:
            self.assertEqual(str(error), "Unrecognized value for parameter \"action\": queryy.")
            return
        self.assertTrue(False)

    def test_handle_wikipedia_api_result_sets_wikipedia_pages_default_sort_if_present_in_wikitext(self):
        wikipedia_page = WikipediaPage(id="fr|Jacques-Henri Bernardin de Saint-Pierre")
        sync_wikipedia_pages.handle_wikipedia_api_result(WIKIPEDIA_API_RESULT_REVISIONS(), [wikipedia_page])
        self.assertEqual(wikipedia_page.default_sort, "Bernardin de Saint-Pierre, Jacques-Henri")

    def test_handle_wikipedia_api_result_returns_continue_if_present(self):
        wikipedia_page = WikipediaPage(id="fr|Jacques-Henri Bernardin de Saint-Pierre")
        continue_dict = {
            'myContinue': 'myContinue'
        }
        api_result = WIKIPEDIA_API_RESULT_REVISIONS()
        api_result.update({'continue': continue_dict})
        self.assertEqual(sync_wikipedia_pages.handle_wikipedia_api_result(api_result, [wikipedia_page]), continue_dict)

    def test_handle_wikipedia_api_result_returns_none_if_continue_is_not_present(self):
        wikipedia_page = WikipediaPage(id="fr|Jacques-Henri Bernardin de Saint-Pierre")
        self.assertIsNone(sync_wikipedia_pages.handle_wikipedia_api_result(WIKIPEDIA_API_RESULT_REVISIONS(), [wikipedia_page]))

    # get_default_sort

    def test_get_default_sort_returns_default_sort_if_present_in_wikitext(self):
        wikitext = "'''Jacques-Henri Bernardin de Saint-Pierre''' (also called '''Bernardin de St. Pierre''') (19 January 1737 [[Le Havre]]  &ndash; 21 January 1814 [[Éragny, Val-d'Oise|Éragny]], [[Val-d'Oise]]) was a [[France|French]] writer and [[botanist]]. He is best known for his 1788 novel ''[[Paul et Virginie]]'', now largely forgotten, but in the 19th century a very popular [[children's book]].\n\n{{DEFAULTSORT:Bernardin de Saint-Pierre, Jacques-Henri}}\n[[Category:École des Ponts ParisTech alumni]]\n"
        self.assertEqual(sync_wikipedia_pages.get_default_sort(wikitext), "Bernardin de Saint-Pierre, Jacques-Henri")

    def test_get_default_sort_returns_none_if_not_present_in_wikitext(self):
        wikitext = "'''Jacques-Henri Bernardin de Saint-Pierre''' (also called '''Bernardin de St. Pierre''') (19 January 1737 [[Le Havre]]  &ndash; 21 January 1814 [[Éragny, Val-d'Oise|Éragny]], [[Val-d'Oise]]) was a [[France|French]] writer and [[botanist]]. He is best known for his 1788 novel ''[[Paul et Virginie]]'', now largely forgotten, but in the 19th century a very popular [[children's book]].\n\n[[Category:École des Ponts ParisTech alumni]]\n"
        self.assertIsNone(sync_wikipedia_pages.get_default_sort(wikitext))
