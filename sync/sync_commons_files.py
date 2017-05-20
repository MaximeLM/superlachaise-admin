import logging, os, importlib.machinery, json, re
from xml.etree import ElementTree
from django.conf import settings
from django.utils.html import strip_tags

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

logger = logging.getLogger(__name__)

def sync(reset=False, ids=None, **kwargs):
    logger.info('== begin sync commons files ==')

    if reset:
        logger.info('Delete existing objects')
        delete_objects()

    orphaned_objects = [] if ids else list(CommonsFile.objects.all())

    commons_files_to_refresh, created = get_or_create_commons_categories_to_refresh(ids)
    logger.info("Found {} Commons files to refresh (created {})".format(len(commons_files_to_refresh), created))
    orphaned_objects = [commons_file for commons_file in orphaned_objects if commons_file not in commons_files_to_refresh]

    request_image_info(commons_files_to_refresh)

    for commons_file in orphaned_objects:
        logger.debug("Deleted CommonsFile "+commons_file.id)
        commons_file.delete()
    logger.info("Deleted {} orphaned objects".format(len(orphaned_objects)))

    logger.info('== end sync commons files ==')

def delete_objects():
    CommonsFile.objects.all().delete()

def get_commons_files_from_commons_categories(commons_categories):
    commons_files, created = ([], 0)

    logger.info("Request {} for category members".format(COMMONS_API_BASE_URL))
    entry_count = 0
    entry_total = len(commons_categories)
    for commons_categories_chunk in sync_utils.make_chunks(list(commons_categories)):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(commons_categories_chunk)

        for commons_category in commons_categories_chunk:
            commons_files_for_category, created_for_category = get_commons_files_from_commons_category(commons_category)
            commons_files.extend([commons_file for commons_file in commons_files_for_category if commons_file not in commons_files])
            created = created + created_for_category
    logger.info(str(entry_count)+"/"+str(entry_total))

    return (commons_files, created)

def get_commons_files_from_commons_category(commons_category):
    commons_files, created = request_category_members(commons_category)

    main_commons_file_id = commons_category.get_main_commons_file_id()
    if main_commons_file_id:
        main_commons_file, was_created = CommonsFile.objects.get_or_create(id=main_commons_file_id)
        if not main_commons_file in commons_files:
            commons_files.append(main_commons_file)
            logger.warning("Main Commons file not in category members for Commons category {}".format(commons_category))
        if was_created:
            logger.debug("Created CommonsFile "+main_commons_file.id)
            created = created + 1
        else:
            logger.debug("Matched CommonsFile "+main_commons_file.id)
        commons_category.main_commons_file = main_commons_file
        commons_category.save()
    else:
        logger.warning("No main Commons file for Commons category {}".format(commons_category))

    return (commons_files, created)

def get_or_create_commons_categories_to_refresh(ids):
    if ids:
        return (list(CommonsFile.objects.filter(id__in=ids)), 0)
    else:
        logger.info('Get Commons files from Commons categories')
        return get_commons_files_from_commons_categories(list(CommonsCategory.objects.all()))

# Commons API

COMMONS_API_BASE_URL = "https://commons.wikimedia.org/w/api.php"
def request_commons_api(commons_query_params):
    result = sync_utils.request(COMMONS_API_BASE_URL, params=commons_query_params)
    return result.json()

class CommonsAPIError(Exception):
    pass

class CommonsAPIMissingFilesError(CommonsAPIError):
    def __init__(self, commons_files):
        super(CommonsAPIMissingFilesError, self).__init__("missing files {}".format(str([commons_file.id for commons_file in commons_files])))
        self.commons_files = commons_files

# Request Category members

def make_category_members_query_params(commons_category):
    return {
        'action': 'query',
        'list': 'categorymembers',
        'cmtitle': 'Category:'+commons_category.id,
        'cmtype': 'file',
        'format': 'json',
    }

def request_category_members(commons_category):
    commons_files = []
    created = 0

    commons_query_params = make_category_members_query_params(commons_category)
    last_continue = {'continue': ''}
    while last_continue:
        logger.debug("last_continue: {}".format(last_continue))
        commons_query_params.update(last_continue)
        result = request_commons_api(commons_query_params)
        last_continue, commons_files_for_page, created_for_page = handle_category_members_result(result)
        commons_files.extend(commons_files_for_page)
        created = created + created_for_page

    commons_category.commons_files.set(commons_files)
    commons_category.save()
    return (commons_files, created)

def handle_category_members_result(result):
    commons_files = []
    created = 0

    if 'error' in result:
        raise CommonsAPIError(result['error']['info'])
    if 'normalized' in result['query']:
        for normalize in result['query']['normalized']:
            from_title = normalize['from']
            to_title = normalize['to']
            logger.warning("Commons category was normalized from \"{}\" to \"{}\"".format(from_title, to_title))
    for commons_file_dict in result['query']['categorymembers']:
        commons_file_id = commons_file_dict['title'][5:]
        commons_file, was_created = CommonsFile.objects.get_or_create(id=commons_file_id)
        if was_created:
            logger.debug("Created CommonsFile "+commons_file.id)
            created = created + 1
        else:
            logger.debug("Matched CommonsFile "+commons_file.id)
        if not commons_file in commons_files:
            commons_files.append(commons_file)
    return (result.get('continue', None), commons_files, created)

# Request Image info

def make_image_info_query_params(commons_files):
    return {
        'action': 'query',
        'prop': 'imageinfo',
        'iiprop': 'url|size|extmetadata',
        'format': 'json',
        'iiurlwidth': 5,
        'titles': '|'.join(['File:'+commons_file.id for commons_file in commons_files]),
    }

def request_image_info(commons_files):
    logger.info("Request {} for image info".format(COMMONS_API_BASE_URL))
    entry_count = 0
    entry_total = len(commons_files)
    for commons_files_chunk in sync_utils.make_chunks(list(commons_files), chunk_size=5):
        logger.info(str(entry_count)+"/"+str(entry_total))
        entry_count = entry_count + len(commons_files_chunk)

        # Prepare commons files
        for commons_file in commons_files_chunk:
            commons_file.author = None
            commons_file.license = None
            commons_file.width = None
            commons_file.height = None
            commons_file.image_url = None
            commons_file.thumbnail_url_template = None

        image_info_query_params = make_image_info_query_params(commons_files_chunk)
        last_continue = {'continue': ''}
        while last_continue:
            logger.debug("last_continue: {}".format(last_continue))
            image_info_query_params.update(last_continue)
            result = request_commons_api(image_info_query_params)
            last_continue = handle_image_info_result(result, commons_files_chunk)

        # Check and save commons categories
        for commons_file in commons_files_chunk:
            if not commons_file.author:
                commons_file.author = ''
            if not commons_file.license:
                commons_file.license = ''
            if not commons_file.width:
                logger.warning("Width is missing for Commons file \"{}\"".format(commons_file))
            if not commons_file.height:
                logger.warning("Height is missing for Commons file \"{}\"".format(commons_file))
            if not commons_file.image_url:
                logger.warning("Image url is missing for Commons file \"{}\"".format(commons_file))
                commons_file.image_url = ''
            if not commons_file.thumbnail_url_template:
                logger.warning("Thumbnail url template is missing for Commons file \"{}\"".format(commons_file))
                commons_file.thumbnail_url_template = ''
            commons_file.save()

    logger.info(str(entry_count)+"/"+str(entry_total))

def handle_image_info_result(result, commons_files_chunk):
    commons_files_by_id = {'File:'+commons_file.id: commons_file for commons_file in commons_files_chunk}
    if 'error' in result:
        raise CommonsAPIError(result['error']['info'])
    if 'normalized' in result['query']:
        for normalize in result['query']['normalized']:
            from_title = normalize['from']
            to_title = normalize['to']
            logger.warning("Commons category was normalized from \"{}\" to \"{}\"".format(from_title, to_title))
            commons_files_by_id[to_title] = commons_files_by_id.pop(from_title)
    for commons_file_dict in result['query']['pages'].values():
        commons_file = commons_files_by_id.pop(commons_file_dict['title'])
        if 'missing' in commons_file_dict:
            raise CommonsAPIMissingFilesError([commons_category])
        if 'imageinfo' in commons_file_dict:
            for image_info_dict in commons_file_dict['imageinfo']:
                if 'extmetadata' in image_info_dict:
                    if 'LicenseShortName' in image_info_dict['extmetadata']:
                        commons_file.license = image_info_dict['extmetadata']['LicenseShortName']['value']
                    if 'Artist' in image_info_dict['extmetadata']:
                        commons_file.author = clean_author(image_info_dict['extmetadata']['Artist']['value'])
                if 'width' in image_info_dict:
                    commons_file.width = image_info_dict['width']
                if 'height' in image_info_dict:
                    commons_file.height = image_info_dict['height']
                if 'url' in image_info_dict:
                    commons_file.image_url = image_info_dict['url']
                if 'thumburl' in image_info_dict:
                    thumbnail_url = image_info_dict['thumburl']
                    if '/5px-' in thumbnail_url:
                        commons_file.thumbnail_url_template = thumbnail_url.replace('/5px-', '/{{width}}px-')
                    else:
                        logger.warning("Invalid thumbnail URL template for Commons file {}".format(commons_file))
    if len(commons_files_by_id) > 0:
        raise CommonsAPIMissingFilesError(commons_files_by_id.values())
    if 'continue' in result:
        return result['continue']

def clean_author(author):

    # Strip HTML
    author = strip_tags(author)

    # Extract creator template
    match_obj = re.search(r'(.*)&#160;.*', author)
    while match_obj:
        author = match_obj.group(1).strip()
        match_obj = re.search(r'(.*)&#160;.*', author)

    # Remove extra information
    match_obj = re.search(r'(.*);.*', author)
    while match_obj:
        author = match_obj.group(1).strip()
        match_obj = re.search(r'(.*)&#160;.*', author)

    # Extract derivative work
    match_obj = re.search(r'.*[Dd]erivative work:(.*)$', author)
    if match_obj:
        author = match_obj.group(1).strip()

    # Extract user
    match_obj = re.search(r'.*[Uu]ser:(.*)$', author)
    if match_obj:
        author = match_obj.group(1).strip()

    # Remove talk link
    author = author.replace('(talk)', '')

    # Remove new lines, strip
    author = author.replace('\n', ' ').strip()

    # Remove leading ~
    if len(author) > 1 and author[0] == '~':
        author = author[1:]

    # Remove multiple spaces
    while '  ' in author:
        author = author.replace('  ', ' ')

    return author
