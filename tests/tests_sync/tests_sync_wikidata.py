import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *
from superlachaise.sync.sync_wikidata import WikidataError, WikidataNoSuchEntityError

# Fixtures

def OPENSTREETMAP_ELEMENT_1():
    return OpenStreetMapElement(
        id="node/2765555563",
        raw_tags=json.dumps({
            "historic": "tomb",
            "name": "Étienne Lamy",
            "sorting_name": "Lamy",
            "wikidata": "Q1218474",
            "name:wikidata": "Q123456",
            "wikimedia_commons": "Category:Grave of Lamy (Père-Lachaise, division 49)",
            "wikipedia": "fr:Étienne Lamy"
        })
    )

def OPENSTREETMAP_ELEMENT_2():
    return OpenStreetMapElement(
        id="way/314136876",
        raw_tags=json.dumps({
            "building": "yes",
            "historic": "tomb",
            "sorting_name": "Panhard",
            "name:wikidata": "Q266561",
            "wikimedia_commons": "Category:Grave of Panhard (Père-Lachaise, division 36)",
            "wikipedia": "fr:René Panhard"
        })
    )

def OPENSTREETMAP_ELEMENT_3():
    return OpenStreetMapElement(
        id="relation/123456",
        raw_tags=json.dumps({
            "building": "yes",
            "historic": "tomb",
            "sorting_name": "Panhard",
            "wikimedia_commons": "Category:Grave of Panhard (Père-Lachaise, division 36)",
            "wikipedia": "fr:René Panhard"
        })
    )

WIKIDATA_API_RESULT_NO_SUCH_ENTITY = {
    "error": {
        "code": "no-such-entity",
        "info": "Could not find such an entity. (Invalid id: Q1235630;Q3144796)",
        "id": "Q1235630;Q3144796",
        "messages": [
            {
                "name": "wikibase-api-no-such-entity",
                "parameters": [],
                "html": {
                    "*": "Could not find such an entity."
                }
            }
        ],
        "*": "See https://www.wikidata.org/w/api.php for API usage. Subscribe to the mediawiki-api-announce mailing list at &lt;https://lists.wikimedia.org/mailman/listinfo/mediawiki-api-announce&gt; for notice of API deprecations and breaking changes."
    },
    "servedby": "mw1197"
}

WIKIDATA_API_RESULT_ERROR = {
    "error": {
        "code": "maxlagapparams",
        "info": "prlevel may not be used without prtype",
        "*": "See https://www.mediawiki.org/w/api.php for API usage."
    }
}

WIKIDATA_API_RESULT_NO_LABELS = {
    "entities": {
        "Q3426652": {
            "type": "item",
            "id": "Q3426652",
            "labels": {},
            "descriptions": {},
            "claims": {},
            "sitelinks": {}
        }
    },
    "success": 1
}

WIKIDATA_API_RESULT_1 = {
    "entities": {
        "Q3426652": {
            "type": "item",
            "id": "Q3426652",
            "labels": {
                "fr": {
                    "language": "fr",
                    "value": "René Mouchotte"
                },
                "en": {
                    "language": "en",
                    "value": "René Mouchotte"
                }
            },
            "descriptions": {
                "en": {
                    "language": "en",
                    "value": "World War II pilot of the French Air Force"
                },
                "fr": {
                    "language": "fr",
                    "value": "aviateur français de la Seconde Guerre mondiale et une figure de la France libre"
                }
            },
            "claims": {
                "P2732": [
                    {
                        "mainsnak": {
                            "snaktype": "value",
                            "property": "P2732",
                            "datavalue": {
                                "value": "47863",
                                "type": "string"
                            },
                            "datatype": "external-id"
                        },
                        "type": "statement",
                        "id": "Q3426652$515C6B2E-A3BC-4C79-BA44-E713EC498DFD",
                        "rank": "normal"
                    }
                ]
            },
            "sitelinks": {
                "commonswiki": {
                    "site": "commonswiki",
                    "title": "Category:René Mouchotte",
                    "badges": []
                },
                "enwiki": {
                    "site": "enwiki",
                    "title": "René Mouchotte",
                    "badges": []
                },
                "frwiki": {
                    "site": "frwiki",
                    "title": "René Mouchotte",
                    "badges": []
                }
            }
        }
    },
    "success": 1
}

class SyncWikidataTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_wikidata_entries(self):
        wikidata_entry = WikidataEntry(id="Q1218474")
        wikidata_entry.save()
        sync_wikidata.delete_objects()
        self.assertEqual(WikidataEntry.objects.all().count(), 0)

    # get_local_wikidata_entries

    def test_get_local_wikidata_entries_returns_all_existing_objects_if_ids_is_none(self):
        wikidata_entry_1 = WikidataEntry(id="Q1218474")
        wikidata_entry_1.save()
        wikidata_entry_2 = WikidataEntry(id="Q266561")
        wikidata_entry_2.save()
        self.assertEqual(
            sync_wikidata.get_local_wikidata_entries(None),
            [wikidata_entry_1, wikidata_entry_2])

    def test_get_local_wikidata_entries_returns_existing_objects_for_ids(self):
        wikidata_entry_1 = WikidataEntry(id="Q1218474")
        wikidata_entry_1.save()
        wikidata_entry_2 = WikidataEntry(id="Q266561")
        wikidata_entry_2.save()
        self.assertEqual(
            sync_wikidata.get_local_wikidata_entries(["Q1218474", "Q123456"]),
            [wikidata_entry_1])

    # get_or_create_wikidata_entries_from_openstreetmap_elements

    def test_get_or_create_wikidata_entries_from_openstreetmap_elements_returns_wikidata_entries_with_first_present_wikidata_id(self):
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_from_openstreetmap_elements(
            [OPENSTREETMAP_ELEMENT_1(), OPENSTREETMAP_ELEMENT_2(), OPENSTREETMAP_ELEMENT_3()],
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual([wikidata_entry.id for wikidata_entry in wikidata_entries], ["Q1218474", "Q266561"])

    def test_get_or_create_wikidata_entries_from_openstreetmap_elements_increments_created_if_wikidata_entry_was_created(self):
        WikidataEntry(id="Q1218474").save()
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_from_openstreetmap_elements(
            [OPENSTREETMAP_ELEMENT_1(), OPENSTREETMAP_ELEMENT_2(), OPENSTREETMAP_ELEMENT_3()],
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual(created, 1)

    def test_get_or_create_wikidata_entries_from_openstreetmap_elements_sets_relation_to_present_wikidata_entry_if_found(self):
        openstreetmap_element_1 = OPENSTREETMAP_ELEMENT_1()
        wikidata_entry = WikidataEntry(id="Q1218474")
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_from_openstreetmap_elements(
            [openstreetmap_element_1, OPENSTREETMAP_ELEMENT_2(), OPENSTREETMAP_ELEMENT_3()],
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual(openstreetmap_element_1.wikidata_entry, wikidata_entry)

    def test_get_or_create_wikidata_entries_from_openstreetmap_elements_sets_relation_to_none_if_no_wikidata_entry_is_found(self):
        openstreetmap_element_3 = OPENSTREETMAP_ELEMENT_3()
        openstreetmap_element_3.wikidata_entry = WikidataEntry(id="Q123456")
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_from_openstreetmap_elements(
            [OPENSTREETMAP_ELEMENT_1(), OPENSTREETMAP_ELEMENT_2(), openstreetmap_element_3],
            ["wikidata", "name:wikidata"]
        )
        self.assertIsNone(openstreetmap_element_3.wikidata_entry)

    # get_or_create_wikidata_entries_to_refresh

    def test_get_or_create_wikidata_entries_to_refresh_returns_wikidata_entries_for_all_openstreetmap_elements_if_ids_is_none(self):
        OPENSTREETMAP_ELEMENT_1().save()
        OPENSTREETMAP_ELEMENT_2().save()
        OPENSTREETMAP_ELEMENT_3().save()
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_to_refresh(None)
        self.assertEqual([wikidata_entry.id for wikidata_entry in wikidata_entries], ["Q1218474", "Q266561"])

    def test_get_or_create_wikidata_entries_to_refresh_returns_created_wikidata_entries_if_ids_is_none(self):
        OPENSTREETMAP_ELEMENT_1().save()
        OPENSTREETMAP_ELEMENT_2().save()
        OPENSTREETMAP_ELEMENT_3().save()
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_to_refresh(None)
        self.assertEqual(created, 2)

    def test_get_or_create_wikidata_entries_to_refresh_returns_wikidata_entries_for_ids_if_ids_is_not_none(self):
        ids = ["Q1218474", "Q266561"]
        for id in ids:
            WikidataEntry(id=id).save()
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_to_refresh(ids)
        self.assertEqual([wikidata_entry.id for wikidata_entry in wikidata_entries], ids)

    def test_get_or_create_wikidata_entries_to_refresh_returns_0_created_if_ids_is_not_none(self):
        ids = ["Q1218474", "Q266561"]
        for id in ids:
            WikidataEntry(id=id).save()
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_to_refresh(ids)
        self.assertEqual(created, 0)

    # make_chunks

    def test_make_chunks_returns_ordered_elements_in_max_size_chunks(self):
        wikidata_entries = [
            WikidataEntry(id="Q1"),
            WikidataEntry(id="Q2"),
            WikidataEntry(id="Q3"),
            WikidataEntry(id="Q4"),
            WikidataEntry(id="Q5"),
        ]
        self.assertEqual(sync_wikidata.make_chunks(wikidata_entries, 2), [
            [wikidata_entries[0], wikidata_entries[1]],
            [wikidata_entries[2], wikidata_entries[3]],
            [wikidata_entries[4]],
        ])

    # make_wikidata_query_params

    def test_make_wikidata_query_params_returns_ids_key_with_wikidata_entries_ids_separated_by_pipes(self):
        wikidata_entries = [
            WikidataEntry(id="Q1218474"),
            WikidataEntry(id="Q266561"),
        ]
        languages = [
            "fr",
            "en",
        ]
        params = sync_wikidata.make_wikidata_query_params(wikidata_entries, languages)
        self.assertEqual(params["ids"], "Q1218474|Q266561")

    def test_make_wikidata_query_params_returns_languages_key_with_languages_separated_by_pipes(self):
        wikidata_entries = [
            WikidataEntry(id="Q1218474"),
            WikidataEntry(id="Q266561"),
        ]
        languages = [
            "fr",
            "en",
        ]
        params = sync_wikidata.make_wikidata_query_params(wikidata_entries, languages)
        self.assertEqual(params["languages"], "fr|en")

    # handle_wikidata_api_result

    def test_handle_wikidata_api_result_raises_no_such_entity_error_with_failing_wikidata_entry(self):
        wikidata_entry = WikidataEntry(id="Q1235630;Q3144796")
        try:
            sync_wikidata.handle_wikidata_api_result(WIKIDATA_API_RESULT_NO_SUCH_ENTITY, [wikidata_entry])
        except WikidataNoSuchEntityError as error:
            self.assertEqual(error.wikidata_entry, wikidata_entry)
            return
        self.assertTrue(False)

    def test_handle_wikidata_api_result_deletes_wikidata_entry_for_no_such_entity_errors(self):
        wikidata_entry = WikidataEntry(id="Q1235630;Q3144796")
        wikidata_entry.save()
        self.assertEqual(WikidataEntry.objects.all().count(), 1)
        try:
            sync_wikidata.handle_wikidata_api_result(WIKIDATA_API_RESULT_NO_SUCH_ENTITY, [wikidata_entry])
        except WikidataNoSuchEntityError as error:
            self.assertEqual(WikidataEntry.objects.all().count(), 0)
            return
        self.assertTrue(False)

    def test_handle_wikidata_api_result_raises_wikidata_errors_with_error_info(self):
        wikidata_entry = WikidataEntry(id="Q1235630")
        try:
            sync_wikidata.handle_wikidata_api_result(WIKIDATA_API_RESULT_ERROR, [wikidata_entry])
        except WikidataError as error:
            self.assertEqual(str(error), "prlevel may not be used without prtype")
            return
        self.assertTrue(False)

    def test_handle_wikidata_api_result_updates_wikidata_entries_with_result(self):
        wikidata_entry = WikidataEntry(id="Q3426652")
        sync_wikidata.handle_wikidata_api_result(WIKIDATA_API_RESULT_1, [wikidata_entry])
        self.assertEqual(wikidata_entry.labels(), WIKIDATA_API_RESULT_1['entities']['Q3426652']['labels'])
        self.assertEqual(wikidata_entry.descriptions(), WIKIDATA_API_RESULT_1['entities']['Q3426652']['descriptions'])
        self.assertEqual(wikidata_entry.claims(), WIKIDATA_API_RESULT_1['entities']['Q3426652']['claims'])
        self.assertEqual(wikidata_entry.sitelinks(), WIKIDATA_API_RESULT_1['entities']['Q3426652']['sitelinks'])

    def test_handle_wikidata_api_result_updates_wikidata_entries_name_with_first_label_if_it_exists(self):
        wikidata_entry = WikidataEntry(id="Q3426652")
        sync_wikidata.handle_wikidata_api_result(WIKIDATA_API_RESULT_1, [wikidata_entry])
        self.assertEqual(wikidata_entry.name, "René Mouchotte")

    def test_handle_wikidata_api_result_updates_wikidata_entries_name_with_empty_string_if_no_label_exists(self):
        wikidata_entry = WikidataEntry(id="Q3426652")
        sync_wikidata.handle_wikidata_api_result(WIKIDATA_API_RESULT_NO_LABELS, [wikidata_entry])
        self.assertEqual(wikidata_entry.name, "")
