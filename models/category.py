import json
from django.db import models

from superlachaise.models import model_validators

class Category(models.Model):

    id = models.CharField(primary_key=True, db_index=True, max_length=1024)
    kind = models.CharField(max_length=1024, blank=True)

    raw_labels = models.TextField(default='{}', validators=[model_validators.validate_JSON])

    # JSON fields

    def labels(self):
        if self.raw_labels:
            return json.loads(self.raw_labels)

    # Fields access

    def get_label(self, language):
        labels = self.labels()
        if labels and language in labels and 'value' in labels[language]:
            return labels[language]['value']

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['id']
        verbose_name = 'Category'
        verbose_name_plural = 'Categories'

    # Export

    def json_object(self):
        return {
            "id": self.id,
            "kind": self.kind,
            "labels": self.labels(),
            "wikidata_entries": [wikidata_category.wikidata_id() for wikidata_category in self.wikidata_categories.all()]
        }
