from superlachaise.models import *

def get_wikipedia_export_object(config):
    wikipedia_pages = WikipediaPage.objects.filter(redirect=None)
    export_object = {
        "about": {
            "source": "https://www.wikipedia.org/",
            "license": "https://creativecommons.org/licenses/by-sa/3.0/",
        },
        "wikipedia_pages": {}
    }

    for wikipedia_page in wikipedia_pages:
        if not wikipedia_page.language in export_object["wikipedia_pages"]:
            export_object["wikipedia_pages"][wikipedia_page.language] = {}
        wikipedia_page_dict = get_wikipedia_page_export_object(wikipedia_page)
        export_object["wikipedia_pages"][wikipedia_page.language][wikipedia_page.title] = wikipedia_page_dict

    return export_object

def get_wikipedia_page_export_object(wikipedia_page):
    return {
        "language": wikipedia_page.language,
        "title": wikipedia_page.title,
        "extract": wikipedia_page.extract,
    }
