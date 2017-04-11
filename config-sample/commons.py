import logging
from superlachaise.models import *

P_PLACE_OF_BURIAL = "P119"
P_COMMONS_CATEGORY = "P373"

F_MAINSNAK = "mainsnak"
F_QUALIFIERS = "qualifiers"

Q_PERE_LACHAISE_CEMETERY = "Q111"

logger = logging.getLogger("superlachaise")

def get_property_id(property_dict):
    try:
        return property_dict['datavalue']['value']['id']
    except KeyError:
        pass

def get_commons_category(wikidata_entry):
    """ Returns a Commons category for a Wikidata entry """

    accepted_locations = [Q_PERE_LACHAISE_CEMETERY]
    claims = wikidata_entry.claims()

    # First look for a "place of burial" claim
    if claims and P_PLACE_OF_BURIAL in claims:
        for place_of_burial in claims[P_INSTANCE_OF]:
            if F_MAINSNAK in place_of_burial and get_property_id(place_of_burial[F_MAINSNAK]) in accepted_locations:
                if F_QUALIFIERS in place_of_burial and P_COMMONS_CATEGORY in place_of_burial[F_QUALIFIERS]:
                    commons_categories = place_of_burial[F_QUALIFIERS][P_COMMONS_CATEGORY]
                    if len(commons_categories) > 1:
                        logger.warning("Multiple commons categories for Wikidata ID {}".format(wikidata_entry.id))
                    for commons_category in commons_categories:
                        commons_category_id = get_property_id(commons_category)
                        if commons_category_id:
                            return commons_category_id

    # Then look for a root commons category
    if claims and P_COMMONS_CATEGORY in claims:
        commons_categories = claims[P_COMMONS_CATEGORY]
        if len(commons_categories) > 1:
            logger.warning("Multiple commons categories for Wikidata ID {}".format(wikidata_entry.id))
        for commons_category in commons_categories:
            commons_category_id = get_property_id(commons_category)
            if commons_category_id:
                return commons_category_id
