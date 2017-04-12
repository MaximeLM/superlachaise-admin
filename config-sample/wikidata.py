from superlachaise.models import *

OPENSTREETMAP_ID_TAGS = [
    "wikidata",
    "name:wikidata"
]

P_INSTANCE_OF = "P31"
P_OF = "P642"

F_MAINSNAK = "mainsnak"
F_QUALIFIERS = "qualifiers"

Q_TOMB = "Q173387"

def get_property_id(property_dict):
    try:
        return property_dict['datavalue']['value']['id']
    except KeyError:
        pass

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
