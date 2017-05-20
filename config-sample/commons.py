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

def get_commons_files_export_object(config):
    commons_files = CommonsFile.objects.all()
    return {
        "about": {
            "source": "https://commons.wikimedia.org/",
            "license": "https://creativecommons.org/licenses/by-sa/3.0/",
        },
        "commons_files": {commons_file.id: get_commons_file_export_object(commons_file) for commons_file in commons_files},
    }

def get_commons_file_export_object(commons_file):
    return {
        "id": commons_file.id,
        "author": commons_file.author if commons_file.author else None,
        "license": commons_file.license if commons_file.license else None,
        "width": commons_file.width,
        "height": commons_file.height,
        "image_url": commons_file.image_url if commons_file.image_url else None,
        "thumbnail_url_template": commons_file.thumbnail_url_template if commons_file.thumbnail_url_template else None,
    }
