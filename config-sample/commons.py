import logging
from superlachaise.models import *

P_INSTANCE_OF = "P31"
P_PLACE_OF_BURIAL = "P119"
P_COMMONS_CATEGORY = "P373"

F_MAINSNAK = "mainsnak"
F_QUALIFIERS = "qualifiers"

Q_HUMAN = "Q5"
Q_PERE_LACHAISE_CEMETERY = "Q311"
Q_PERE_LACHAISE_CREMATORIUM = "Q3006253"

logger = logging.getLogger("superlachaise")

def get_property_id(property_dict):
    try:
        return property_dict['datavalue']['value']['id']
    except KeyError:
        pass

def get_property_value(property_dict):
    try:
        return property_dict['datavalue']['value']
    except KeyError:
        pass

def get_commons_category_id(wikidata_entry):
    """ Returns a Commons category ID from a Wikidata entry """

    accepted_locations = [Q_PERE_LACHAISE_CEMETERY, Q_PERE_LACHAISE_CREMATORIUM]
    claims = wikidata_entry.claims()

    # Get instance_of values from entry
    instance_of_ids = []
    if claims and P_INSTANCE_OF in claims:
        for instance_of in claims[P_INSTANCE_OF]:
            if F_MAINSNAK in instance_of:
                instance_of_id = get_property_id(instance_of[F_MAINSNAK])
                if instance_of_id:
                    instance_of_ids.append(instance_of_id)

    if Q_HUMAN in instance_of_ids:
        # If the entry is a human, look for "place of burial" claim
        if P_PLACE_OF_BURIAL in claims:
            for place_of_burial in claims[P_PLACE_OF_BURIAL]:
                if F_MAINSNAK in place_of_burial and get_property_id(place_of_burial[F_MAINSNAK]) in accepted_locations:
                    if F_QUALIFIERS in place_of_burial and P_COMMONS_CATEGORY in place_of_burial[F_QUALIFIERS]:
                        commons_categories = place_of_burial[F_QUALIFIERS][P_COMMONS_CATEGORY]
                        if len(commons_categories) > 1:
                            logger.warning("Multiple commons categories for Wikidata entry {} - {}".format(wikidata_entry.id, wikidata_entry.name))
                        for commons_category in commons_categories:
                            commons_category_id = get_property_value(commons_category)
                            if commons_category_id:
                                return commons_category_id
    else:
        # Then look for a root commons category
        if claims and P_COMMONS_CATEGORY in claims:
            commons_categories = claims[P_COMMONS_CATEGORY]
            if len(commons_categories) > 1:
                logger.warning("Multiple commons categories for Wikidata entry {} - {}".format(wikidata_entry.id, wikidata_entry.name))
            for commons_category in commons_categories:
                if F_MAINSNAK in commons_category:
                    commons_category_id = get_property_value(commons_category[F_MAINSNAK])
                    if commons_category_id:
                        return commons_category_id
