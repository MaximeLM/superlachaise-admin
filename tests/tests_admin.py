from django.test import TestCase

from superlachaise.admin.utils import AdminUtils

class AdminUtilsTestCase(TestCase):

    # html_link

    def test_html_link_returns_html_link_format_with_url_and_name_if_url_is_not_none_and_name_is_not_none(self):
        url = 'http://my_url'
        name = 'my_name'
        html_link = AdminUtils.html_link(url, name)
        self.assertEqual(html_link, AdminUtils.HTML_LINK_FORMAT.format(url=url, name=name))

    def test_html_link_returns_html_link_format_with_url_and_url_if_url_is_not_none_and_name_is_none(self):
        url = 'http://my_url'
        html_link = AdminUtils.html_link(url)
        self.assertEqual(html_link, AdminUtils.HTML_LINK_FORMAT.format(url=url, name=url))

    def test_html_link_returns_none_if_url_is_none(self):
        self.assertIsNone(AdminUtils.html_link(None))

    def test_html_link_escapes_quote_in_url(self):
        url = "http://my'_url"
        html_link = AdminUtils.html_link(url)
        self.assertEqual(html_link, AdminUtils.HTML_LINK_FORMAT.format(url=url.replace("'", "%27"), name=url))
