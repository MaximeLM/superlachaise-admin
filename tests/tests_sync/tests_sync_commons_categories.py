import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *
from superlachaise.sync.sync_commons_categories import CommonsAPIError, CommonsAPIMissingPagesError

# Fixtures

def COMMONS_API_RESULT():
    return {
        "batchcomplete":"",
        "query": {
            "pages": {
                "6998361": {
                    'pageid': 6998361,
                    'ns': 0,
                    'title': 'Category:Jacques-Henri Bernardin de Saint-Pierre',
                    'revisions': [{
                        'contentformat': 'text/x-wiki',
                        'contentmodel': 'wikitext',
                        '*': "<onlyinclude>{{Mérimée|type=inscrit|PA00086780}}{{Category definition: Object\n|image            = Père-Lachaise - Division 32 - Moline 01.jpg\n|type             = tomb\n|artist           = \n|title            = {{tomb of|Alexandre Moline de Saint-Yon}} (1786-1870)\n|description      = \n|date             = \n|dimensions       = \n|medium           = \n|inscriptions     = {{inscription|medium=engraving|lang=fr|Alexandre Pierre Moline de S<sup>t</sup> Yon. général de division, décédé à Bordeaux le 17 novembre 1870, dans sa 85<sup>e</sup> année.}}{{inscription|medium=engraving|lang=fr|A<sup>{{illegible}}</sup> G<sup>elle</sup> Moline de S<sup>t</sup> Yon. morte le 28 {{illegible}} à l'âge de 93 ans.}}\n|object history   = \n|references       = \n|notes            = \n|gallery          = {{institution:Cimetière du Père-Lachaise}}\n|location         = {{Père Lachaise location |division=32|line=1 |Moiroux= |Salomon=JJ5 |street=chemin de la Bédoyère |concession=}}\n|wikidata         = \n}}{{Object location|48.858765|2.394809}}</onlyinclude>\n\n{{DEFAULTSORT:Moline de Saint-Yon}}\n[[Category:Graves in the Père-Lachaise Cemetery]]\n[[Category:Père-Lachaise Cemetery - Division 31]]\n[[Category:Monuments historiques in France (graves)]]\n[[Category:Monuments historiques inscrits in the Père-Lachaise Cemetery]]\n[[Category:Alexandre Moline de Saint-Yon|grave]]\n[[Category:Chemin de La Bédoyère (Père-Lachaise)]]\n[[Category:Alexandre Moline de Saint-Yon]]\n"
                    }]
                }
            }
        }
    }

COMMONS_API_RESULT_MISSING = {
    "batchcomplete":"",
    "query": {
        "pages": {
            "-1": {
                'ns': 0,
                'title': "Category:Jim_Morrison",
                'missing': ""
            }
        }
    }
}

COMMONS_API_RESULT_ERROR = {
   "error":{
       "code":"unknown_action",
       "info":"Unrecognized value for parameter \"action\": queryy.",
       "*":"See https://commons.wikimedia.org/w/api.php for API usage. Subscribe to the mediawiki-api-announce mailing list at &lt;https://lists.wikimedia.org/mailman/listinfo/mediawiki-api-announce&gt; for notice of API deprecations and breaking changes."
   },
   "servedby":"mw1197"
}

COMMONS_API_RESULT_REDIRECT = {
    "batchcomplete":"",
    "query": {
        "pages": {
            "6998361": {
                'pageid': 6998361,
                'ns': 0,
                'title': 'Category:Grave of Joseph Fourier',
                'revisions': [{
                    'contentformat': 'text/x-wiki',
                    'contentmodel': 'wikitext',
                    '*': "{{Category redirect|Category:Grave of Fourier (Père-Lachaise, division 18)}}\n"
                }]
            }
        }
    }
}

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

    # get_redirects

    def test_get_redirects_returns_redirects_from_commons_categories(self):
        commons_categories = [
            CommonsCategory(id="Jim_1", redirect=CommonsCategory(id="Jim_2")),
            CommonsCategory(id="Jim_3"),
            CommonsCategory(id="Jim_4", redirect=CommonsCategory(id="Jim_5")),
        ]
        redirects = sync_commons_categories.get_redirects(commons_categories)
        self.assertEqual([redirect.id for redirect in redirects], ["Jim_2", "Jim_5"])

    # make_commons_query_params

    def test_make_commons_query_params_returns_titles_key_with_commons_categories_titles_prefixed_by_category_separated_by_pipes(self):
        commons_categories = [
            CommonsCategory(id="Jim_1"),
            CommonsCategory(id="Jim_2"),
        ]
        params = sync_commons_categories.make_commons_query_params(commons_categories)
        self.assertEqual(params["titles"], "Category:Jim_1|Category:Jim_2")

    # handle_commons_api_result

    def test_handle_commons_api_result_raises_missing_pages_error_for_commons_categories_not_in_result(self):
        commons_category_1 = CommonsCategory(id="Jim_Morrison")
        commons_category_2 = CommonsCategory(id="Jacques-Henri Bernardin de Saint-Pierre")
        try:
            sync_commons_categories.handle_commons_api_result(COMMONS_API_RESULT(), [commons_category_1, commons_category_2])
        except CommonsAPIMissingPagesError as error:
            self.assertEqual([commons_category.id for commons_category in error.commons_categories], ["Jim_Morrison"])
            return
        self.assertTrue(False)

    def test_handle_commons_api_result_raises_missing_pages_error_with_missing_wikipedia_page(self):
        commons_category_1 = CommonsCategory(id="Jim_Morrison")
        commons_category_2 = CommonsCategory(id="Jacques-Henri Bernardin de Saint-Pierre")
        try:
            sync_commons_categories.handle_commons_api_result(COMMONS_API_RESULT_MISSING, [commons_category_1, commons_category_2])
        except CommonsAPIMissingPagesError as error:
            self.assertEqual([commons_category.id for commons_category in error.commons_categories], ["Jim_Morrison"])
            return
        self.assertTrue(False)

    def test_handle_commons_api_result_raises_commons_errors_with_error_info(self):
        commons_category = CommonsCategory(id="Jim_Morrison")
        try:
            sync_commons_categories.handle_commons_api_result(COMMONS_API_RESULT_ERROR, [commons_category])
        except CommonsAPIError as error:
            self.assertEqual(str(error), "Unrecognized value for parameter \"action\": queryy.")
            return
        self.assertTrue(False)

    def test_handle_commons_api_result_returns_continue_if_present(self):
        commons_category = CommonsCategory(id="Jacques-Henri Bernardin de Saint-Pierre")
        continue_dict = {
            'myContinue': 'myContinue'
        }
        api_result = COMMONS_API_RESULT()
        api_result.update({'continue': continue_dict})
        self.assertEqual(sync_commons_categories.handle_commons_api_result(api_result, [commons_category]), continue_dict)

    def test_handle_commons_api_result_returns_none_if_continue_is_not_present(self):
        commons_category = CommonsCategory(id="Jacques-Henri Bernardin de Saint-Pierre")
        self.assertIsNone(sync_commons_categories.handle_commons_api_result(COMMONS_API_RESULT(), [commons_category]))

    def test_handle_commons_api_result_succeeds_if_title_was_normalized(self):
        commons_category = CommonsCategory(id="Jacques-Henri_Bernardin_de_Saint-Pierre")
        api_result = COMMONS_API_RESULT()
        api_result['query'].update({
            'normalized': [{
                'from': 'Category:Jacques-Henri_Bernardin_de_Saint-Pierre',
                'to': 'Category:Jacques-Henri Bernardin de Saint-Pierre'
            }]
        })
        sync_commons_categories.handle_commons_api_result(api_result, [commons_category])

    def test_handle_commons_api_result_sets_wikipedia_pages_default_sort_if_present_in_wikitext(self):
        commons_category = CommonsCategory(id="Jacques-Henri Bernardin de Saint-Pierre")
        sync_commons_categories.handle_commons_api_result(COMMONS_API_RESULT(), [commons_category])
        self.assertEqual(commons_category.default_sort, "Moline de Saint-Yon")

    def test_handle_commons_api_result_sets_wikipedia_pages_image_if_present_in_wikitext(self):
        commons_category = CommonsCategory(id="Jacques-Henri Bernardin de Saint-Pierre")
        sync_commons_categories.handle_commons_api_result(COMMONS_API_RESULT(), [commons_category])
        self.assertEqual(commons_category.image, "Père-Lachaise - Division 32 - Moline 01.jpg")

    def test_handle_commons_api_result_sets_wikipedia_pages_redirect_if_present_in_wikitext(self):
        commons_category = CommonsCategory(id="Grave of Joseph Fourier")
        sync_commons_categories.handle_commons_api_result(COMMONS_API_RESULT_REDIRECT, [commons_category])
        self.assertEqual(commons_category.redirect.id, "Grave of Fourier (Père-Lachaise, division 18)")

    # get_default_sort

    def test_get_default_sort_returns_default_sort_if_present_in_wikitext(self):
        wikitext = "'''Jacques-Henri Bernardin de Saint-Pierre''' (also called '''Bernardin de St. Pierre''') (19 January 1737 [[Le Havre]]  &ndash; 21 January 1814 [[Éragny, Val-d'Oise|Éragny]], [[Val-d'Oise]]) was a [[France|French]] writer and [[botanist]]. He is best known for his 1788 novel ''[[Paul et Virginie]]'', now largely forgotten, but in the 19th century a very popular [[children's book]].\n\n{{DEFAULTSORT:Bernardin de Saint-Pierre, Jacques-Henri}}\n[[Category:École des Ponts ParisTech alumni]]\n"
        self.assertEqual(sync_commons_categories.get_default_sort(wikitext), "Bernardin de Saint-Pierre, Jacques-Henri")

    def test_get_default_sort_returns_none_if_not_present_in_wikitext(self):
        wikitext = "'''Jacques-Henri Bernardin de Saint-Pierre''' (also called '''Bernardin de St. Pierre''') (19 January 1737 [[Le Havre]]  &ndash; 21 January 1814 [[Éragny, Val-d'Oise|Éragny]], [[Val-d'Oise]]) was a [[France|French]] writer and [[botanist]]. He is best known for his 1788 novel ''[[Paul et Virginie]]'', now largely forgotten, but in the 19th century a very popular [[children's book]].\n\n[[Category:École des Ponts ParisTech alumni]]\n"
        self.assertIsNone(sync_commons_categories.get_default_sort(wikitext))

    # get_image

    def test_get_image_returns_image_if_present_in_wikitext(self):
        wikitext = "<onlyinclude>{{Mérimée|type=inscrit|PA00086780}}{{Category definition: Object\n |image            = Père-Lachaise - Division 32 - Moline 01.jpg\n|type             = tomb\n|artist           = \n|title            = {{tomb of|Alexandre Moline de Saint-Yon}} (1786-1870)\n|description      = \n|date             = \n|dimensions       = \n|medium           = \n|inscriptions     = {{inscription|medium=engraving|lang=fr|Alexandre Pierre Moline de S<sup>t</sup> Yon. général de division, décédé à Bordeaux le 17 novembre 1870, dans sa 85<sup>e</sup> année.}}{{inscription|medium=engraving|lang=fr|A<sup>{{illegible}}</sup> G<sup>elle</sup> Moline de S<sup>t</sup> Yon. morte le 28 {{illegible}} à l'âge de 93 ans.}}\n|object history   = \n|references       = \n|notes            = \n|gallery          = {{institution:Cimetière du Père-Lachaise}}\n|location         = {{Père Lachaise location |division=32|line=1 |Moiroux= |Salomon=JJ5 |street=chemin de la Bédoyère |concession=}}\n|wikidata         = \n}}{{Object location|48.858765|2.394809}}</onlyinclude>\n\n{{DEFAULTSORT:Moline de Saint-Yon}}\n[[Category:Graves in the Père-Lachaise Cemetery]]\n[[Category:Père-Lachaise Cemetery - Division 31]]\n[[Category:Monuments historiques in France (graves)]]\n[[Category:Monuments historiques inscrits in the Père-Lachaise Cemetery]]\n[[Category:Alexandre Moline de Saint-Yon|grave]]\n[[Category:Chemin de La Bédoyère (Père-Lachaise)]]\n[[Category:Alexandre Moline de Saint-Yon]]\n"
        self.assertEqual(sync_commons_categories.get_image(wikitext), "Père-Lachaise - Division 32 - Moline 01.jpg")

    def test_get_image_returns_none_if_not_present_in_wikitext(self):
        wikitext = "<onlyinclude>{{Mérimée|type=inscrit|PA00086780}}{{Category definition: Object\n|type             = tomb\n|artist           = \n|title            = {{tomb of|Alexandre Moline de Saint-Yon}} (1786-1870)\n|description      = \n|date             = \n|dimensions       = \n|medium           = \n|inscriptions     = {{inscription|medium=engraving|lang=fr|Alexandre Pierre Moline de S<sup>t</sup> Yon. général de division, décédé à Bordeaux le 17 novembre 1870, dans sa 85<sup>e</sup> année.}}{{inscription|medium=engraving|lang=fr|A<sup>{{illegible}}</sup> G<sup>elle</sup> Moline de S<sup>t</sup> Yon. morte le 28 {{illegible}} à l'âge de 93 ans.}}\n|object history   = \n|references       = \n|notes            = \n|gallery          = {{institution:Cimetière du Père-Lachaise}}\n|location         = {{Père Lachaise location |division=32|line=1 |Moiroux= |Salomon=JJ5 |street=chemin de la Bédoyère |concession=}}\n|wikidata         = \n}}{{Object location|48.858765|2.394809}}</onlyinclude>\n\n{{DEFAULTSORT:Moline de Saint-Yon}}\n[[Category:Graves in the Père-Lachaise Cemetery]]\n[[Category:Père-Lachaise Cemetery - Division 31]]\n[[Category:Monuments historiques in France (graves)]]\n[[Category:Monuments historiques inscrits in the Père-Lachaise Cemetery]]\n[[Category:Alexandre Moline de Saint-Yon|grave]]\n[[Category:Chemin de La Bédoyère (Père-Lachaise)]]\n[[Category:Alexandre Moline de Saint-Yon]]\n"
        self.assertIsNone(sync_commons_categories.get_image(wikitext))

    # get_redirect_id

    def test_get_redirect_id_returns_redirect_id_if_present_in_wikitext(self):
        wikitext = "{{Category redirect|Category:Grave of Fourier (Père-Lachaise, division 18)}}\n"
        self.assertEqual(sync_commons_categories.get_redirect_id(wikitext), "Grave of Fourier (Père-Lachaise, division 18)")

    def test_get_redirect_id_returns_none_if_not_present_in_wikitext(self):
        wikitext = "<onlyinclude>{{Mérimée|type=inscrit|PA00086780}}{{Category definition: Object\n|type             = tomb\n|artist           = \n|title            = {{tomb of|Alexandre Moline de Saint-Yon}} (1786-1870)\n|description      = \n|date             = \n|dimensions       = \n|medium           = \n|inscriptions     = {{inscription|medium=engraving|lang=fr|Alexandre Pierre Moline de S<sup>t</sup> Yon. général de division, décédé à Bordeaux le 17 novembre 1870, dans sa 85<sup>e</sup> année.}}{{inscription|medium=engraving|lang=fr|A<sup>{{illegible}}</sup> G<sup>elle</sup> Moline de S<sup>t</sup> Yon. morte le 28 {{illegible}} à l'âge de 93 ans.}}\n|object history   = \n|references       = \n|notes            = \n|gallery          = {{institution:Cimetière du Père-Lachaise}}\n|location         = {{Père Lachaise location |division=32|line=1 |Moiroux= |Salomon=JJ5 |street=chemin de la Bédoyère |concession=}}\n|wikidata         = \n}}{{Object location|48.858765|2.394809}}</onlyinclude>\n\n{{DEFAULTSORT:Moline de Saint-Yon}}\n[[Category:Graves in the Père-Lachaise Cemetery]]\n[[Category:Père-Lachaise Cemetery - Division 31]]\n[[Category:Monuments historiques in France (graves)]]\n[[Category:Monuments historiques inscrits in the Père-Lachaise Cemetery]]\n[[Category:Alexandre Moline de Saint-Yon|grave]]\n[[Category:Chemin de La Bédoyère (Père-Lachaise)]]\n[[Category:Alexandre Moline de Saint-Yon]]\n"
        self.assertIsNone(sync_commons_categories.get_redirect_id(wikitext))
