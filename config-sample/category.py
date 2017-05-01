from superlachaise.models import *

CATEGORIES = [
    {
        "id": "sample",
        "kind": "instance_of",
        "labels": {
            "en": "sample",
            "fr": "exemple"
        },
        "wikidata_categories": [
            "Q179700"
        ]
    }
]

def get_category_export_object(config):
    categories = Category.objects.all()
    return {
        "categories": {category.id: get_single_category_export_object(category, config.base.LANGUAGES) for category in categories},
    }

def get_single_category_export_object(category, languages):
    export_object = {
        "id": category.id,
        "kind": category.kind,
    }

    labels = category.labels()
    for language in languages:
        export_object[language] = {
            "label": labels[language],
        } if language in labels else None

    return export_object
