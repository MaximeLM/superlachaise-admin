import logging, os, importlib.machinery, json, re
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync wikipedia pages ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(WikipediaPage.objects.all())

    wikipedia_pages_to_refresh, created = get_or_create_wikipedia_pages_to_refresh(ids)
    logger.info("Found {} Wikipedia pages to refresh (created {})".format(sum(len(wikipedia_pages) for wikipedia_pages in wikipedia_pages_to_refresh.values()), created))

    for (language, wikipedia_pages) in wikipedia_pages_to_refresh.items():
        orphaned_objects = [wikipedia_page for wikipedia_page in orphaned_objects if wikipedia_page not in wikipedia_pages]

    request_wikipedia_pages(wikipedia_pages_to_refresh)

    redirects = get_redirects(wikipedia_pages_to_refresh)
    redirects_len = sum(len(wikipedia_pages) for wikipedia_pages in redirects.values())
    while redirects_len > 0:
        logger.info("Found {} redirect Wikipedia pages to refresh".format(redirects_len))
        for (language, wikipedia_pages) in redirects.items():
            orphaned_objects = [wikipedia_page for wikipedia_page in orphaned_objects if wikipedia_page not in wikipedia_pages]
        request_wikipedia_pages(redirects)
        redirects = get_redirects(redirects)
        redirects_len = sum(len(wikipedia_pages) for wikipedia_pages in redirects.values())

    for wikipedia_page in orphaned_objects:
        logger.debug("Deleted WikipediaPage "+wikipedia_page.id)
        wikipedia_page.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync wikipedia pages ==')

def delete_objects():
    WikipediaPage.objects.all().delete()

# Prepare model

def get_or_create_wikipedia_pages_from_wikidata_entries(wikidata_entries, languages):
    wikipedia_pages = {language:[] for language in languages}
    created = 0

    for wikidata_entry in wikidata_entries:
        wikipedia_pages_for_wikidata_entry = []
        for language in languages:
            title = wikidata_entry.get_sitelink("{}wiki".format(language))
            if title:
                wikipedia_id = "{}|{}".format(language, title)
                wikipedia_page, was_created = WikipediaPage.objects.get_or_create(id=wikipedia_id)
                if not wikipedia_page in wikipedia_pages_for_wikidata_entry:
                    wikipedia_pages_for_wikidata_entry.append(wikipedia_page)
                if was_created:
                    logger.debug("Created WikipediaPage "+wikipedia_id)
                    created = created + 1
                else:
                    logger.debug("Matched WikipediaPage "+wikipedia_id)
                if not wikipedia_page in wikipedia_pages[language]:
                    wikipedia_pages[language].append(wikipedia_page)
            else:
                logger.warning("Wikipedia page for language '{}' is missing for wikidata entry {}".format(language, str(wikidata_entry)))
        wikidata_entry.wikipedia_pages.set(wikipedia_pages_for_wikidata_entry)

    return (wikipedia_pages, created)

def get_or_create_wikipedia_pages_to_refresh(ids, languages=config.base.LANGUAGES):
    if ids:
        wikipedia_pages = {language:[] for language in languages}
        for wikipedia_page in WikipediaPage.objects.filter(id__in=ids):
            (language, title) = wikipedia_page.id_parts()
            if wikipedia_page not in wikipedia_pages[language]:
                wikipedia_pages[language].append(wikipedia_page)
        return (wikipedia_pages, 0)
    else:
        logger.info('List Wikipedia pages from Wikidata entries')
        return get_or_create_wikipedia_pages_from_wikidata_entries(list(WikidataEntry.objects.all()), languages)

def get_redirects(wikipedia_pages, languages=config.base.LANGUAGES):
    redirects = {language:[] for language in languages}

    for (language, wikipedia_pages_for_language) in wikipedia_pages.items():
        for wikipedia_page in wikipedia_pages_for_language:
            if wikipedia_page.redirect:
                if not wikipedia_page.redirect in redirects[language]:
                    redirects[language].append(wikipedia_page.redirect)

    return redirects

# Request Wikipedia API

def make_wikipedia_query_params(wikipedia_pages):
    return {
        'action': 'query',
        'prop': 'revisions',
        'rvprop': 'content',
        'format': 'json',
        'titles': '|'.join([wikipedia_page.id_parts()[1] for wikipedia_page in wikipedia_pages]),
    }

WIKIPEDIA_API_BASE_URL = "https://{language}.wikipedia.org/w/api.php"
def request_wikipedia_api(wikipedia_query_params, language):
    logger.debug("wikipedia_query_params:")
    logger.debug(wikipedia_query_params)

    # Request data
    result = sync_utils.request(WIKIPEDIA_API_BASE_URL.format(language=language), params=wikipedia_query_params)

    # Return JSON
    return result.json()

def request_wikipedia_pages(wikipedia_pages):
    for (language, wikipedia_pages_for_language) in wikipedia_pages.items():
        logger.info("Request {}".format(WIKIPEDIA_API_BASE_URL.format(language=language)))
        entry_count = 0
        entry_total = len(wikipedia_pages_for_language)
        for wikipedia_pages_chunk in sync_utils.make_chunks(list(wikipedia_pages_for_language)):
            logger.info(str(entry_count)+"/"+str(entry_total))
            entry_count = entry_count + len(wikipedia_pages_chunk)

            # Prepare wikipedia pages
            for wikipedia_page in wikipedia_pages_chunk:
                wikipedia_page.default_sort = None
                wikipedia_page.redirect = None

            wikipedia_query_params = make_wikipedia_query_params(wikipedia_pages_chunk)
            last_continue = {'continue': ''}
            while last_continue:
                logger.debug("last_continue: {}".format(last_continue))
                wikipedia_query_params.update(last_continue)
                result = request_wikipedia_api(wikipedia_query_params, language)
                last_continue = handle_wikipedia_api_result(result, wikipedia_pages_chunk)

            # Check and save wikipedia pages
            for wikipedia_page in wikipedia_pages_chunk:
                if not wikipedia_page.default_sort:
                    logger.warning("Default sort is missing for Wikipedia page {}".format(wikipedia_page.id))
                    wikipedia_page.default_sort = ''
                if wikipedia_page.redirect:
                    logger.warning("Wikipedia page \"{}\" is a redirect for \"{}\"".format(wikipedia_page.id, wikipedia_page.redirect.id))
                    if '#' in wikipedia_page.redirect.id:
                        logger.warning("Redirect page \"{}\" contains an anchor '#'".format(wikipedia_page.redirect.id))
                wikipedia_page.save()
        logger.info(str(entry_count)+"/"+str(entry_total))
        config.wikipedia.post_sync_wikipedia_pages(wikipedia_pages_for_language)

class WikipediaAPIError(Exception):
    pass

class WikipediaAPIMissingPagesError(WikipediaAPIError):
    def __init__(self, wikipedia_pages):
        super(WikipediaAPIMissingPagesError, self).__init__("missing pages {}".format(str([wikipedia_page.id for wikipedia_page in wikipedia_pages])))
        self.wikipedia_pages = wikipedia_pages

def handle_wikipedia_api_result(result, wikipedia_pages):
    if 'error' in result:
        raise WikipediaAPIError(result['error']['info'])
    wikipedia_pages_by_title = {wikipedia_page.id_parts()[1]:wikipedia_page for wikipedia_page in wikipedia_pages}
    if 'normalized' in result['query']:
        for normalize in result['query']['normalized']:
            from_title = normalize['from']
            to_title = normalize['to']
            logger.warning("Wikipedia page was normalized from \"{}\" to \"{}\"".format(from_title, to_title))
            wikipedia_pages_by_title[to_title] = wikipedia_pages_by_title.pop(from_title)
    for wikipedia_page_dict in result['query']['pages'].values():
        wikipedia_page = wikipedia_pages_by_title.pop(wikipedia_page_dict['title'])
        if 'missing' in wikipedia_page_dict:
            raise WikipediaAPIMissingPagesError([wikipedia_page])
        if 'revisions' in wikipedia_page_dict:
            wikitext = wikipedia_page_dict['revisions'][0]['*']
            wikipedia_page.default_sort = get_default_sort(wikitext)
            redirect_id = get_redirect_id(wikitext)
            if redirect_id:
                wikipedia_id = wikipedia_page.id_parts()[0] + '|' + redirect_id
                redirect, was_created = WikipediaPage.objects.get_or_create(id=wikipedia_id)
                if was_created:
                    logger.debug("Created redirect WikipediaPage "+redirect.id)
                else:
                    logger.debug("Matched redirect WikipediaPage "+redirect.id)
                wikipedia_page.redirect = redirect
    if len(wikipedia_pages_by_title) > 0:
        raise WikipediaAPIMissingPagesError(wikipedia_pages_by_title.values())
    if 'continue' in result:
        return result['continue']

DEFAULT_SORT_PATTERN = re.compile("^{{DEFAULTSORT:[\s]*(.*)[\s]*}}$")
def get_default_sort(wikitext):
    for line in wikitext.split('\n'):
        match = DEFAULT_SORT_PATTERN.match(line)
        if match:
            return match.group(1)

REDIRECT_PATTERN = re.compile("^[\s]*#REDIRECT[\s]*\[\[(.*)\]\][\s]*$")
def get_redirect_id(wikitext):
    for line in wikitext.split('\n'):
        match = REDIRECT_PATTERN.match(line)
        if match:
            return match.group(1)
