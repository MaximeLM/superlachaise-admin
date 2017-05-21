#CONTACT_INFO = "Website and/or email address"

LANGUAGES = [
    "fr",
    "en"
]

def export_targets(config):
    return {
        "openstreetmap_elements": config.openstreetmap.get_openstreetmap_export_object,
        "wikidata_entries": config.wikidata.get_wikidata_export_object,
        "wikipedia_pages": config.wikipedia.get_wikipedia_export_object,
        "commons_categories": config.commons.get_commons_categories_export_object,
        "commons_files": config.commons.get_commons_files_export_object,
        "categories": config.category.get_category_export_object,
    }
