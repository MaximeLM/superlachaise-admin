from django.utils.safestring import mark_safe

class AdminUtils():
    HTML_LINK_FORMAT = u"<a href='{url}'>{name}</a>"

    @classmethod
    def html_link(cls, url, name=None):
        """ Return an HTML <a> tag for an URL and optional name (defaults to the URL) """
        if url:
            return mark_safe("<a href='{url}'>{name}</a>".format(url=url.replace("'","%27"), name=name if name else url))
