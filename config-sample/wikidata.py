from superlachaise.models import *
from superlachaise.models.wikidata import *

OPENSTREETMAP_ID_TAGS = [
    "wikidata",
    "name:wikidata"
]

P_OF = "P642"
P_SEX_OR_GENDER = "P21"
P_OCCUPATION = "P106"

Q_TOMB = "Q173387"

def get_secondary_wikidata_entries(wikidata_entry):
    """ List other Wikidata entries IDs to sync for a primary Wikidata entry """
    wikidata_entries = []

    # Add "grave of" wikidata entries
    claims = wikidata_entry.claims()
    if claims and P_INSTANCE_OF in claims:
        for instance_of in claims[P_INSTANCE_OF]:
            if F_MAINSNAK in instance_of and get_property_id(instance_of[F_MAINSNAK]) == Q_TOMB:
                if F_QUALIFIERS in instance_of and P_OF in instance_of[F_QUALIFIERS]:
                    for grave_of in instance_of[F_QUALIFIERS][P_OF]:
                        grave_of_id = get_property_id(grave_of)
                        if grave_of_id:
                            wikidata_entries.append(grave_of_id)

    return wikidata_entries

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
                        category_id = kind + '/' + get_property_id(category[F_MAINSNAK])
                        if category_id and category_id not in wikidata_categories:
                            wikidata_categories.append(category_id)

    return wikidata_categories
