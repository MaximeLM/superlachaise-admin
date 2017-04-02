import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

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

class SyncWikidataTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_wikidata_entries(self):
        wikidata_entry = WikidataEntry(id="Q1218474")
        wikidata_entry.save()
        sync_wikidata.delete_objects()
        self.assertEqual(WikidataEntry.objects.all().count(), 0)

    # get_first_matching_wikidata_id

    def test_get_first_matching_wikidata_id_returns_first_openstreetmap_id_tag_value_if_present(self):
        wikidata_id = sync_wikidata.get_first_matching_wikidata_id(
            OPENSTREETMAP_ELEMENT_1(),
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual(wikidata_id, "Q1218474")

    def test_get_first_matching_wikidata_id_returns_next_openstreetmap_id_tag_value_if_present_and_first_tag_is_not_present(self):
        wikidata_id = sync_wikidata.get_first_matching_wikidata_id(
            OPENSTREETMAP_ELEMENT_2(),
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual(wikidata_id, "Q266561")

    def test_get_first_matching_wikidata_id_returns_none_if_no_openstreetmap_id_tag_is_present(self):
        wikidata_id = sync_wikidata.get_first_matching_wikidata_id(
            OPENSTREETMAP_ELEMENT_1(),
            ["myTag", "myOtherTag"]
        )
        self.assertIsNone(wikidata_id)

    # get_or_create_wikidata_entries_from_openstreetmap_elements

    def test_get_or_create_wikidata_entries_from_openstreetmap_elements_returns_wikidata_entries_with_first_matching_wikidata_id(self):
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

    def test_get_or_create_wikidata_entries_from_openstreetmap_elements_sets_relation_to_matching_wikidata_entry_relation_if_found(self):
        openstreetmap_element_1 = OPENSTREETMAP_ELEMENT_1()
        wikidata_entries, created = sync_wikidata.get_or_create_wikidata_entries_from_openstreetmap_elements(
            [openstreetmap_element_1, OPENSTREETMAP_ELEMENT_2(), OPENSTREETMAP_ELEMENT_3()],
            ["wikidata", "name:wikidata"]
        )
        self.assertEqual(openstreetmap_element_1.wikidata_entry, wikidata_entries[0])

    def test_get_or_create_wikidata_entries_from_openstreetmap_elements_sets_relation_to_none_if_no_match_is_found(self):
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
