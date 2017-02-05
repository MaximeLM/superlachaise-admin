import requests
import logging
import importlib.machinery
import os
from django.conf import settings

config = importlib.machinery.SourceFileLoader('config', os.path.join(settings.SUPERLACHAISE_CONFIG, '__init__.py')).load_module()
from config import *
from superlachaise import apps

logger = logging.getLogger(__name__)

def request(url, verb="get", headers={}, **args):
    headers['User-Agent'] = "superlachaise-python/{version} ({contact_info})".format(version=apps.APP_VERSION, contact_info=config.common.CONTACT_INFO)
    args['headers'] = headers
    action = getattr(requests, verb, None)
    logger.debug(verb+" "+url)
    response = action(url, args)
    logger.debug("{url} ({status_code}):".format(url=url, status_code=response.status_code))
    logger.debug(response.text)
    return response
