import json
from django.test import TestCase

from superlachaise.sync import *
from superlachaise.models import *

class SyncCommonsCategoriesTestCase(TestCase):

    # delete_objects

    def test_delete_objects_deletes_existing_commons_categories(self):
        commons_category = CommonsCategory(id="Jim Morrison")
        commons_category.save()
        sync_commons_categories.delete_objects()
        self.assertEqual(CommonsCategory.objects.all().count(), 0)
