import logging

from superlachaise.models import *
from superlachaise.models.wikidata import *

logger = logging.getLogger("superlachaise")

F_MAINSNAK = WikidataEntry.F_MAINSNAK
F_QUALIFIERS = WikidataEntry.F_QUALIFIERS

P_OF = "P642"
P_SEX_OR_GENDER = "P21"
P_OCCUPATION = "P106"
P_BURIAL_PLOT_REFERENCE = "P965"
P_PLACE_OF_BURIAL = "P119"
P_COMMONS_CATEGORY = "P373"
P_PART_OF = "P361"
P_LOCATION = "P276"
P_DATE_OF_BIRTH = "P569"
P_DATE_OF_DEATH = "P570"
P_INSTANCE_OF = WikidataEntry.P_INSTANCE_OF

Q_HUMAN = "Q5"
Q_TOMB = "Q173387"
Q_PERE_LACHAISE_CEMETERY = "Q311"
Q_PERE_LACHAISE_CREMATORIUM = "Q3006253"
Q_GRAVE_OF_JIM_MORRISON = "Q24265482"

accepted_locations = [Q_PERE_LACHAISE_CEMETERY, Q_PERE_LACHAISE_CREMATORIUM, Q_GRAVE_OF_JIM_MORRISON]

def get_secondary_wikidata_entries(wikidata_entry):
    """ List other Wikidata entries IDs to sync for a primary Wikidata entry """
    wikidata_entries = []

    # Add "grave of" wikidata entries
    claims = wikidata_entry.claims()
    if claims and P_INSTANCE_OF in claims:
        for instance_of in claims[P_INSTANCE_OF]:
            if F_MAINSNAK in instance_of and wikidata_entry.get_property_id(instance_of[F_MAINSNAK]) == Q_TOMB:
                if F_QUALIFIERS in instance_of and P_OF in instance_of[F_QUALIFIERS]:
                    for grave_of in instance_of[F_QUALIFIERS][P_OF]:
                        grave_of_id = wikidata_entry.get_property_id(grave_of)
                        if grave_of_id:
                            wikidata_entries.append(grave_of_id)

    return wikidata_entries

def post_sync_wikidata_entries(wikidata_entries):
    pass

def get_commons_category_id(wikidata_entry):
    """ Returns a Commons category ID from a Wikidata entry """

    claims = wikidata_entry.claims()

    if Q_HUMAN in wikidata_entry.get_instance_of_ids(claims):
        # If the entry is a human, look for "place of burial" claim
        if P_PLACE_OF_BURIAL in claims:
            for place_of_burial in claims[P_PLACE_OF_BURIAL]:
                if F_MAINSNAK in place_of_burial and wikidata_entry.get_property_id(place_of_burial[F_MAINSNAK]) in accepted_locations:
                    if F_QUALIFIERS in place_of_burial and P_COMMONS_CATEGORY in place_of_burial[F_QUALIFIERS]:
                        commons_categories = place_of_burial[F_QUALIFIERS][P_COMMONS_CATEGORY]
                        if len(commons_categories) > 1:
                            logger.warning("Multiple commons categories for Wikidata entry {} - {}".format(wikidata_entry.id, wikidata_entry.name))
                        for commons_category in commons_categories:
                            commons_category_id = wikidata_entry.get_property_value(commons_category)
                            if commons_category_id:
                                return commons_category_id
    elif claims:
        # If the entry is a part of the Père Lachaise cemetery, look for a root commons category
        location_accepted = False
        for location_qualifier in [P_PART_OF, P_LOCATION, P_PLACE_OF_BURIAL]:
            if location_qualifier in claims:
                for location in claims[location_qualifier]:
                    if F_MAINSNAK in location and wikidata_entry.get_property_id(location[F_MAINSNAK]) in accepted_locations:
                        location_accepted = True
                        break
        if location_accepted and P_COMMONS_CATEGORY in claims:
            commons_categories = claims[P_COMMONS_CATEGORY]
            if len(commons_categories) > 1:
                logger.warning("Multiple commons categories for Wikidata entry {} - {}".format(wikidata_entry.id, wikidata_entry.name))
            for commons_category in commons_categories:
                if F_MAINSNAK in commons_category:
                    commons_category_id = wikidata_entry.get_property_value(commons_category[F_MAINSNAK])
                    if commons_category_id:
                        return commons_category_id

def get_wikidata_categories(wikidata_entry):
    """ List Wikidata properties that can be used to categorize the wikidata entry """
    wikidata_categories = []

    claims_for_categories = [(P_INSTANCE_OF, "instance_of"), (P_SEX_OR_GENDER, "sex_or_gender"), (P_OCCUPATION, "occupation")]

    claims = wikidata_entry.claims()
    if claims:
        for (claim, kind) in claims_for_categories:
            if claim in claims:
                for category in claims[claim]:
                    if F_MAINSNAK in category:
                        category_id = kind + '/' + wikidata_entry.get_property_id(category[F_MAINSNAK])
                        if category_id and category_id not in wikidata_categories:
                            wikidata_categories.append(category_id)

    return wikidata_categories

def post_sync_wikidata_categories(wikidata_categories):
    pass

def get_wikidata_export_object(config):
    wikidata_entries = WikidataEntry.objects.all()
    return {
        "about": {
            "source": "https://www.wikidata.org/",
            "license": "https://creativecommons.org/publicdomain/zero/1.0/",
        },
        "wikidata_entries": {wikidata_entry.id: get_wikidata_entry_export_object(wikidata_entry, config.base.LANGUAGES) for wikidata_entry in wikidata_entries},
    }

def get_wikidata_entry_export_object(wikidata_entry, languages):
    claims = wikidata_entry.claims()

    export_object = {
        "id": wikidata_entry.id,
    }

    for language in languages:
        wikipedia_page = wikidata_entry.get_wikipedia_page(language)
        export_object[language] = {
            "label": wikidata_entry.get_label(language),
            "description": wikidata_entry.get_description(language),
            "wikipedia_page": wikipedia_page.id_parts()[1] if wikipedia_page else None,
            "default_sort": wikidata_entry.get_default_sort(language),
        }

    commons_category = wikidata_entry.get_commons_category()
    export_object["commons_category"] = commons_category.id if commons_category else None

    export_object["categories"] = [category.id for category in wikidata_entry.get_categories()]
    export_object["burial_plot_reference"] = get_burial_plot_reference(wikidata_entry, claims)

    if Q_HUMAN in wikidata_entry.get_instance_of_ids(claims):
        for (date_field, claim) in [("date_of_birth", P_DATE_OF_BIRTH), ("date_of_death", P_DATE_OF_DEATH)]:
            date_dict = wikidata_entry.get_date_dict(claims, claim)
            export_object[date_field] = date_dict
            if not date_dict:
                logger.warning("{} is missing for Wikidata entry {}".format(date_field, wikidata_entry))

    return export_object

def get_burial_plot_reference(wikidata_entry, claims):
    if P_BURIAL_PLOT_REFERENCE in claims:
        if len(claims[P_BURIAL_PLOT_REFERENCE]) > 1:
            logger.warning("Multiple burial plot references for Wikidata entry {}".format(wikidata_entry))
        burial_plot_reference = claims[P_BURIAL_PLOT_REFERENCE][0]
        if F_MAINSNAK in burial_plot_reference:
            return wikidata_entry.get_property_value(burial_plot_reference[F_MAINSNAK])
    if P_PLACE_OF_BURIAL in claims:
        for place_of_burial in claims[P_PLACE_OF_BURIAL]:
            if F_MAINSNAK in place_of_burial and wikidata_entry.get_property_id(place_of_burial[F_MAINSNAK]) in accepted_locations:
                if F_QUALIFIERS in place_of_burial and P_BURIAL_PLOT_REFERENCE in place_of_burial[F_QUALIFIERS]:
                    burial_plot_references = place_of_burial[F_QUALIFIERS][P_BURIAL_PLOT_REFERENCE]
                    if len(burial_plot_references) > 1:
                        logger.warning("Multiple burial plot references for Wikidata entry {}".format(wikidata_entry))
                    return wikidata_entry.get_property_value(burial_plot_references[0])
    logger.warning("No burial plot reference for Wikidata entry {}".format(wikidata_entry))
