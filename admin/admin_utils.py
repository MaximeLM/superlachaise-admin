from django.utils.html import format_html
from django.core.urlresolvers import reverse

HTML_LINK_FORMAT = "<a href='{url}'>{name}</a>"
def html_link(url, name=None):
    """ Return an HTML <a> tag for an URL and optional name (defaults to the URL) """
    if url:
        return format_html(HTML_LINK_FORMAT, url=url, name=name if name else url)

REVERSE_PATH_FORMAT = "admin:{}_{}_change"
def change_page_url(object):
    """ Return the URL for the change page of an object """
    if object and object.pk:
        app_name = object._meta.app_label
        reverse_name = object.__class__.__name__.lower()
        reverse_path = REVERSE_PATH_FORMAT.format(app_name, reverse_name)
        url = reverse(reverse_path, args=(object.pk,))
        return url
