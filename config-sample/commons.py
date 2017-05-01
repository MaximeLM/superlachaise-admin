from superlachaise.models import *

def post_sync_commons_categories(commons_categories):
    pass

def get_commons_export_object(config):
    commons_categories = CommonsCategory.objects.filter(redirect=None)
    return {
        "about": {
            "source": "https://commons.wikimedia.org/",
            "license": "https://creativecommons.org/licenses/by-sa/3.0/",
        },
        "commons_categories": {commons_category.id: get_commons_category_export_object(commons_category) for commons_category in commons_categories},
    }

def get_commons_category_export_object(commons_category):
    return {
        "id": commons_category.id,
        "main_image": commons_category.main_image,
    }
