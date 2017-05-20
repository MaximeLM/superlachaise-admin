from superlachaise.models import *

def get_commons_categories_export_object(config):
    commons_categories = CommonsCategory.objects.filter(redirect=None)
    return {
        "about": {
            "source": "https://commons.wikimedia.org/",
            "license": "https://creativecommons.org/licenses/by-sa/3.0/",
        },
        "commons_categories": {commons_category.id: get_commons_category_export_object(commons_category) for commons_category in commons_categories},
    }

def get_commons_category_export_object(commons_category):
    commons_files = []
    if commons_category.main_commons_file:
        commons_files.append(commons_category.main_commons_file.id)
    commons_files.extend([commons_file.id for commons_file in commons_category.commons_files.all() if commons_file.id not in commons_files])
    return {
        "id": commons_category.id,
        "commons_files": commons_files,
    }
