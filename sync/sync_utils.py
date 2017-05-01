import requests, logging, importlib.machinery, os
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise import apps

logger = logging.getLogger(__name__)

def request(url, verb="get", headers={}, params={}, data=None):
    if not headers:
        headers = {}
    headers['User-Agent'] = "superlachaise-python/{version} ({contact_info})".format(version=apps.APP_VERSION, contact_info=config.base.CONTACT_INFO)
    action = getattr(requests, verb, None)
    logger.debug(verb+" "+url)
    response = action(url, headers=headers, params=params, data=data)
    logger.debug("{url} ({status_code}):".format(url=url, status_code=response.status_code))
    logger.debug(response.text)
    return response

def make_chunks(objects, chunk_size=50):
    """ Cut the list in chunks of a specified size """
    return [objects[i:i+chunk_size] for i in range(0, len(objects), chunk_size)]
