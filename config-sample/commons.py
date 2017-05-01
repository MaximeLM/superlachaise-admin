import logging
from superlachaise.models import *
from superlachaise.models.wikidata import *

P_PLACE_OF_BURIAL = "P119"
P_COMMONS_CATEGORY = "P373"
P_PART_OF = "P361"
P_LOCATION = "P276"

Q_HUMAN = "Q5"
Q_PERE_LACHAISE_CEMETERY = "Q311"
Q_PERE_LACHAISE_CREMATORIUM = "Q3006253"
Q_GRAVE_OF_JIM_MORRISON = "Q24265482"

logger = logging.getLogger("superlachaise")

def get_commons_category_id(wikidata_entry):
    """ Returns a Commons category ID from a Wikidata entry """

    accepted_locations = [Q_PERE_LACHAISE_CEMETERY, Q_PERE_LACHAISE_CREMATORIUM, Q_GRAVE_OF_JIM_MORRISON]
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
    elif claims:
        # If the entry is a part of the Père Lachaise cemetery, look for a root commons category
        location_accepted = False
        for location_qualifier in [P_PART_OF, P_LOCATION, P_PLACE_OF_BURIAL]:
            if location_qualifier in claims:
                for location in claims[location_qualifier]:
                    if F_MAINSNAK in location and get_property_id(location[F_MAINSNAK]) in accepted_locations:
                        location_accepted = True
                        break
        if location_accepted and P_COMMONS_CATEGORY in claims:
            commons_categories = claims[P_COMMONS_CATEGORY]
            if len(commons_categories) > 1:
                logger.warning("Multiple commons categories for Wikidata entry {} - {}".format(wikidata_entry.id, wikidata_entry.name))
            for commons_category in commons_categories:
                if F_MAINSNAK in commons_category:
                    commons_category_id = get_property_value(commons_category[F_MAINSNAK])
                    if commons_category_id:
                        return commons_category_id

def post_sync_commons_categories(commons_categories):
    pass
