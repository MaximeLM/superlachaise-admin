from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *
from superlachaise.sync import sync_utils

class SyncUtilsTestCase(TestCase):

    # make_chunks

    def test_make_chunks_returns_ordered_elements_in_max_size_chunks(self):
        commons_categories = [
            CommonsCategory(id="Jim_1"),
            CommonsCategory(id="Jim_2"),
            CommonsCategory(id="Jim_3"),
            CommonsCategory(id="Jim_4"),
            CommonsCategory(id="Jim_5"),
        ]
        self.assertEqual(sync_utils.make_chunks(commons_categories, 2), [
            [commons_categories[0], commons_categories[1]],
            [commons_categories[2], commons_categories[3]],
            [commons_categories[4]],
        ])
