import requests
import logging

logger = logging.getLogger(__name__)

def request(url, verb="get", **args):
    action = getattr(requests, verb, None)
    logger.debug(verb+" "+url)
    response = action(url, args)
    logger.debug("{url} ({status_code}):".format(url=url, status_code=response.status_code))
    logger.debug(response.text)
    return response
