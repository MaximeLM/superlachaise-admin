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
P_COMMEMORATES = "P547"
P_MAIN_SUBJECT = "P921"

Q_HUMAN = "Q5"
Q_GRAVE = "Q173387"
Q_TOMB = "Q381885"
Q_PERE_LACHAISE_CEMETERY = "Q311"
Q_PERE_LACHAISE_CREMATORIUM = "Q3006253"
Q_MONUMENT = "Q4989906"
Q_MEMORIAL = "Q5003624"
Q_WAR_MEMORIAL = "Q575759"
Q_CARDIOTAPH = "Q18168545"

accepted_locations = [Q_PERE_LACHAISE_CEMETERY, Q_PERE_LACHAISE_CREMATORIUM]

KIND_GRAVE_OF = "grave_of"
KIND_GRAVE = "grave"
KIND_MONUMENT = "monument"
KIND_SUBJECT = "subject"
accepted_kinds = {
    KIND_GRAVE_OF: [Q_HUMAN],
    KIND_GRAVE: [Q_GRAVE, Q_TOMB, Q_CARDIOTAPH],
    KIND_MONUMENT: [Q_MONUMENT, Q_MEMORIAL, Q_WAR_MEMORIAL],
}

def get_kind(wikidata_entry):
    claims = wikidata_entry.claims()
    if not claims:
        return None

    kind = None
    instance_of_ids = wikidata_entry.get_instance_of_ids(claims)
    for instance_of_id in instance_of_ids:
        for accepted_kind, accepted_instances_of in accepted_kinds.items():
            if instance_of_id in accepted_instances_of:
                if kind and kind != accepted_kind:
                    logger.warning("Duplicate kinds {} and {} for Wikidata entry {}, using {}".format(kind, accepted_kind, wikidata_entry, kind))
                else:
                    kind = accepted_kind

    if wikidata_entry.openstreetmap_elements.count() == 0 and wikidata_entry.primary_wikidata_entries.filter(kind=KIND_GRAVE).count() == 0:
        # A non primary wikidata entry which is not a secondary entry of a grave is a subject
        return KIND_SUBJECT
    elif kind:
        # For other entries, check that the location is accepted
        accepted_location = False
        if kind == KIND_GRAVE_OF:
            if P_PLACE_OF_BURIAL in claims:
                for place_of_burial in claims[P_PLACE_OF_BURIAL]:
                    location_id = wikidata_entry.get_property_id(place_of_burial[F_MAINSNAK])
                    if location_id in accepted_locations:
                        return kind
                    else:
                        location_wikidata_entries = WikidataEntry.objects.filter(id=location_id)
                        if location_wikidata_entries.count() == 1:
                            location_wikidata_entry = location_wikidata_entries[0]
                            if get_kind(location_wikidata_entry):
                                return kind
        else:
            for location_qualifier in [P_PART_OF, P_LOCATION, P_PLACE_OF_BURIAL]:
                if location_qualifier in claims:
                    for location in claims[location_qualifier]:
                        location_id = wikidata_entry.get_property_id(location[F_MAINSNAK])
                        if location_id in accepted_locations:
                            return kind
                        else:
                            location_wikidata_entries = WikidataEntry.objects.filter(id=location_id)
                            if location_wikidata_entries.count() == 1:
                                location_wikidata_entry = location_wikidata_entries[0]
                                if get_kind(location_wikidata_entry):
                                    return kind
        logger.warning("Wikidata entry {} is not located in a accepted location".format(wikidata_entry))
        return None

def get_secondary_wikidata_entries(wikidata_entry):
    """ List other Wikidata entries IDs to sync for a primary Wikidata entry """
    wikidata_entries = []

    claims = wikidata_entry.claims()
    if not claims or not wikidata_entry.kind:
        return []

    # Add "grave of" wikidata entries
    if wikidata_entry.kind == KIND_GRAVE and P_INSTANCE_OF in claims:
        for instance_of in claims[P_INSTANCE_OF]:
            if F_QUALIFIERS in instance_of and P_OF in instance_of[F_QUALIFIERS]:
                for grave_of in instance_of[F_QUALIFIERS][P_OF]:
                    grave_of_id = wikidata_entry.get_property_id(grave_of)
                    if grave_of_id:
                        wikidata_entries.append(grave_of_id)
        if len(wikidata_entries) == 0:
            logger.warning("Wikidata entry {} of kind {} has no secondary entries".format(wikidata_entry, wikidata_entry.kind))

    # Add "commemorates" wikidata entries
    if wikidata_entry.kind == KIND_MONUMENT:
        for monument_claim in [P_COMMEMORATES, P_MAIN_SUBJECT]:
            if monument_claim in claims:
                for claim in claims[monument_claim]:
                    claim_id = wikidata_entry.get_property_id(claim[F_MAINSNAK])
                    if claim_id:
                        wikidata_entries.append(claim_id)
        if len(wikidata_entries) == 0:
            logger.warning("Wikidata entry {} of kind {} has no secondary entries".format(wikidata_entry, wikidata_entry.kind))

    return wikidata_entries

def post_sync_wikidata_entries(wikidata_entries):
    pass

def should_sync_wikipedia_pages_for_wikidata_entry(wikidata_entry):
    return wikidata_entry.kind != KIND_GRAVE

def get_commons_category_id(wikidata_entry):
    """ Returns a Commons category ID from a Wikidata entry """

    claims = wikidata_entry.claims()
    if not claims or not wikidata_entry.kind:
        return None

    # Only for primary wikidata entries
    if wikidata_entry.openstreetmap_elements.count() == 0:
        return None

    if wikidata_entry.kind == KIND_GRAVE_OF:
        # Look for "place of burial" claim
        if P_PLACE_OF_BURIAL in claims:
            for place_of_burial in claims[P_PLACE_OF_BURIAL]:
                if wikidata_entry.get_property_id(place_of_burial[F_MAINSNAK]) in accepted_locations:
                    if F_QUALIFIERS in place_of_burial and P_COMMONS_CATEGORY in place_of_burial[F_QUALIFIERS]:
                        commons_categories = place_of_burial[F_QUALIFIERS][P_COMMONS_CATEGORY]
                        if len(commons_categories) > 1:
                            logger.warning("Multiple commons categories for Wikidata entry {}".format(wikidata_entry))
                        for commons_category in commons_categories:
                            commons_category_id = wikidata_entry.get_property_value(commons_category)
                            if commons_category_id:
                                return commons_category_id
        logger.warning("No Commons category ID found for Wikidata entry {}".format(wikidata_entry))
    elif wikidata_entry.kind in [KIND_GRAVE, KIND_MONUMENT]:
        # Look for a root commons category
        if P_COMMONS_CATEGORY in claims:
            commons_categories = claims[P_COMMONS_CATEGORY]
            if len(commons_categories) > 1:
                logger.warning("Multiple commons categories for Wikidata entry {}".format(wikidata_entry))
            for commons_category in commons_categories:
                commons_category_id = wikidata_entry.get_property_value(commons_category[F_MAINSNAK])
                if commons_category_id:
                    return commons_category_id
        logger.warning("No Commons category ID found for Wikidata entry {}".format(wikidata_entry))

def get_wikidata_categories(wikidata_entry):
    """ List Wikidata properties that can be used to categorize the wikidata entry """
    wikidata_categories = []

    claims = wikidata_entry.claims()
    if not claims or not wikidata_entry.kind:
        return []

    claims_for_categories = []
    if wikidata_entry.kind in [KIND_GRAVE, KIND_MONUMENT]:
        claims_for_categories.append((P_INSTANCE_OF, "instance_of"))
    if wikidata_entry.kind == KIND_GRAVE_OF:
        claims_for_categories.extend([(P_SEX_OR_GENDER, "sex_or_gender"), (P_OCCUPATION, "occupation")])

    for (claim, kind) in claims_for_categories:
        if claim in claims:
            for category in claims[claim]:
                category_id = kind + '/' + wikidata_entry.get_property_id(category[F_MAINSNAK])
                if category_id and category_id not in wikidata_categories:
                    wikidata_categories.append(category_id)

    return wikidata_categories

def post_sync_wikidata_categories(wikidata_categories):
    pass

def get_wikidata_export_object(config):
    wikidata_entries = WikidataEntry.objects.all()
    export_object = {
        "about": {
            "source": "https://www.wikidata.org/",
            "license": "https://creativecommons.org/publicdomain/zero/1.0/",
        },
        "wikidata_entries": {
            KIND_MONUMENT: {},
            KIND_GRAVE: {},
            KIND_GRAVE_OF: {},
        },
    }

    for wikidata_entry in WikidataEntry.objects.exclude(kind__exact='').exclude(kind=KIND_SUBJECT):
        export_object["wikidata_entries"][wikidata_entry.kind].update(get_wikidata_entry_export_object(wikidata_entry, config.base.LANGUAGES))

    return export_object

def get_wikidata_entry_export_object(wikidata_entry, languages):
    claims = wikidata_entry.claims()
    if not claims or not wikidata_entry.kind:
        return {}

    if get_notable_wikidata_entry(wikidata_entry) != wikidata_entry:
        return {}

    is_primary_wikidata_entry = (wikidata_entry.openstreetmap_elements.count() > 0)

    export_object = {
        "id": wikidata_entry.id,
        "kind": wikidata_entry.kind,
    }

    for language in languages:
        wikipedia_page = wikidata_entry.get_wikipedia_page(language)
        export_object[language] = {
            "label": wikidata_entry.get_label(language),
            "default_sort": wikidata_entry.get_default_sort(language),
        }
        if wikidata_entry.kind != KIND_GRAVE:
            export_object[language]["wikipedia_page"] = wikipedia_page.id_parts()[1] if wikipedia_page else None
        if wikidata_entry.kind == KIND_GRAVE_OF:
            export_object[language]["description"] = wikidata_entry.get_description(language)


    if is_primary_wikidata_entry:
        commons_category = wikidata_entry.get_commons_category()
        export_object["commons_category"] = commons_category.id if commons_category else None
        export_object["burial_plot_reference"] = get_burial_plot_reference(wikidata_entry, claims)

    export_object["categories"] = [category.id for category in wikidata_entry.get_categories()]

    secondary_wikidata_entries = get_notable_secondary_entries(wikidata_entry)
    # If the entry has no wikipedia page and a single subject, use it as wikipedia page
    if wikidata_entry.kind != KIND_GRAVE and wikidata_entry.wikipedia_pages.count() == 0:
        subject_wikidata_entries = wikidata_entry.secondary_wikidata_entries.filter(kind=KIND_SUBJECT)
        if len(subject_wikidata_entries) > 1:
            logger.warning("Wikidata entry {} has more than one subject".format(wikidata_entry))
        if len(subject_wikidata_entries) >= 1:
            subject_wikidata_entry = subject_wikidata_entries[0]
            wikipedia_page = subject_wikidata_entry.get_wikipedia_page(language)
            for language in languages:
                export_object[language]["wikipedia_page"] = wikipedia_page.id_parts()[1] if wikipedia_page else None
        else:
            logger.warning("Wikidata entry {} has no wikipedia page".format(wikidata_entry))
    if wikidata_entry.kind == KIND_GRAVE:
        export_object["secondary_wikidata_entries"] = [wikidata_entry.id for wikidata_entry in secondary_wikidata_entries]

    if wikidata_entry.kind == KIND_GRAVE_OF:
        for (date_field, claim) in [("date_of_birth", P_DATE_OF_BIRTH), ("date_of_death", P_DATE_OF_DEATH)]:
            date_dict = wikidata_entry.get_date_dict(claim, claims)
            export_object[date_field] = date_dict
            if not date_dict:
                logger.warning("{} is missing for Wikidata entry {}".format(date_field, wikidata_entry))

    return {
        wikidata_entry.id: export_object,
    }

def get_notable_wikidata_entry(wikidata_entry):
    if wikidata_entry.kind == KIND_GRAVE:
        # Replace grave with single grave_of with wikipedia page
        notable_grave_of = get_notable_secondary_entries(wikidata_entry)
        if len(notable_grave_of) == 1:
            return notable_grave_of[0]
    return wikidata_entry

def get_notable_secondary_entries(wikidata_entry):
    if wikidata_entry.kind == KIND_GRAVE:
        # Skip grave of with no wikipedia pages
        grave_of_wikidata_entries = list(wikidata_entry.secondary_wikidata_entries.filter(kind=KIND_GRAVE_OF))
        grave_of_wikidata_entries = [wikidata_entry for wikidata_entry in grave_of_wikidata_entries if wikidata_entry.wikipedia_pages.count() > 0]
        if len(grave_of_wikidata_entries) > 0:
            return grave_of_wikidata_entries
    return list(wikidata_entry.secondary_wikidata_entries.exclude(kind__exact=''))

def get_burial_plot_reference(wikidata_entry, claims):
    if P_BURIAL_PLOT_REFERENCE in claims:
        if len(claims[P_BURIAL_PLOT_REFERENCE]) > 1:
            logger.warning("Multiple burial plot references for Wikidata entry {}".format(wikidata_entry))
        burial_plot_reference = claims[P_BURIAL_PLOT_REFERENCE][0]
        return wikidata_entry.get_property_value(burial_plot_reference[F_MAINSNAK])
    if P_PLACE_OF_BURIAL in claims:
        for place_of_burial in claims[P_PLACE_OF_BURIAL]:
            if wikidata_entry.get_property_id(place_of_burial[F_MAINSNAK]) in accepted_locations:
                if F_QUALIFIERS in place_of_burial and P_BURIAL_PLOT_REFERENCE in place_of_burial[F_QUALIFIERS]:
                    burial_plot_references = place_of_burial[F_QUALIFIERS][P_BURIAL_PLOT_REFERENCE]
                    if len(burial_plot_references) > 1:
                        logger.warning("Multiple burial plot references for Wikidata entry {}".format(wikidata_entry))
                    return wikidata_entry.get_property_value(burial_plot_references[0])
    logger.warning("No burial plot reference for Wikidata entry {}".format(wikidata_entry))
