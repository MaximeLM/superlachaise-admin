from django.utils.safestring import mark_safe

HTML_LINK_FORMAT = u"<a href='{url}'>{name}</a>"
def html_link(url, name=None):
    """ Return an HTML <a> tag for an URL and optional name (defaults to the URL) """
    if url:
        return mark_safe(HTML_LINK_FORMAT.format(url=url.replace("'","%27"), name=name if name else url))
