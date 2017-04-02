from django.test import TestCase
from django.utils.html import format_html

from superlachaise.admin import *
from superlachaise.models import *

class AdminUtilsTestCase(TestCase):

    # html_link

    def test_html_link_returns_html_link_format_with_url_and_name_if_url_is_not_none_and_name_is_not_none(self):
        url = 'http://my_url'
        name = 'my_name'
        html_link = admin_utils.html_link(url, name)
        self.assertEqual(html_link, format_html(admin_utils.HTML_LINK_FORMAT, url=url, name=name))

    def test_html_link_returns_html_link_format_with_url_and_url_if_url_is_not_none_and_name_is_none(self):
        url = 'http://my_url'
        html_link = admin_utils.html_link(url)
        self.assertEqual(html_link, format_html(admin_utils.HTML_LINK_FORMAT, url=url, name=url))

    def test_html_link_returns_none_if_url_is_none(self):
        self.assertIsNone(admin_utils.html_link(None))

    # change_page_url

    def test_change_page_url_returns_not_none_if_object_is_not_none(self):
        self.assertIsNotNone(admin_utils.change_page_url(OpenStreetMapElement(id="node/123456")))

    def test_change_page_url_returns_none_if_object_is_none(self):
        self.assertIsNone(admin_utils.change_page_url(None))
