#CONTACT_INFO = "Website and/or email address"

LANGUAGES = [
    "fr",
    "en"
]

def export_targets(config):
    return {
        "openstreetmap": config.openstreetmap.get_openstreetmap_export_object,
        "wikidata": config.wikidata.get_wikidata_export_object,
        "commons": config.commons.get_commons_export_object,
        "category": config.category.get_category_export_object,
    }
