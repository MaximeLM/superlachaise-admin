from superlachaise.models import *

def get_wikipedia_export_object(config):
    wikipedia_pages = WikipediaPage.objects.filter(redirect=None)
    return {
        "about": {
            "source": "https://www.wikipedia.org/",
            "license": "https://creativecommons.org/licenses/by-sa/3.0/",
        },
        "wikipedia_pages": [get_wikipedia_page_export_object(wikipedia_page) for wikipedia_page in wikipedia_pages]
    }

def get_wikipedia_page_export_object(wikipedia_page):
    return {
        "language": wikipedia_page.language,
        "title": wikipedia_page.title,
        "extract": wikipedia_page.extract,
    }
