import json
from django.db import models

from superlachaise.models import model_validators

class WikidataEntry(models.Model):

    # Q<numeric_id>
    id = models.CharField(primary_key=True, db_index=True, max_length=255, validators=[model_validators.validate_wikidata_id])
    name = models.CharField(max_length=255, blank=True)

    raw_labels = models.TextField(default='{}', validators=[model_validators.validate_JSON])
    raw_descriptions = models.TextField(default='{}', validators=[model_validators.validate_JSON])
    raw_claims = models.TextField(default='{}', validators=[model_validators.validate_JSON])
    raw_sitelinks = models.TextField(default='{}', validators=[model_validators.validate_JSON])

    secondary_entries = models.ManyToManyField('self', blank=True, symmetrical=False)

    # JSON fields

    def labels(self):
        if self.raw_labels:
            return json.loads(self.raw_labels)

    def descriptions(self):
        if self.raw_descriptions:
            return json.loads(self.raw_descriptions)

    def claims(self):
        if self.raw_claims:
            return json.loads(self.raw_claims)

    def sitelinks(self):
        if self.raw_sitelinks:
            return json.loads(self.raw_sitelinks)

    # Fields access

    def get_label(self, language):
        labels = self.labels()
        if labels and language in labels and 'value' in labels[language]:
            return labels[language]['value']

    def get_description(self, language):
        descriptions = self.descriptions()
        if descriptions and language in descriptions and 'value' in descriptions[language]:
            return descriptions[language]['value']

    WIKIDATA_URL_FORMAT = "https://www.wikidata.org/wiki/{id}"
    def wikidata_url(self):
        if self.id:
            return WikidataEntry.WIKIDATA_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id + " - " + self.name

    class Meta:
        ordering = ['id']
        verbose_name = 'Wikidata entry'
        verbose_name_plural = 'Wikidata entries'
