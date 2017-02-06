import json
from django.db import models

from superlachaise.models import model_validators

class WikidataEntry(models.Model):

    # Q<numeric_id>
    id = models.CharField(primary_key=True, db_index=True, max_length=255, validators=[model_validators.validate_wikidata_id])

    raw_json = models.TextField(default='{}', validators=[model_validators.validate_JSON], verbose_name="raw JSON")

    def json(self):
        if self.raw_json:
            return json.loads(self.raw_json)

    WIKIDATA_URL_FORMAT = "https://www.wikidata.org/wiki/{id}"
    def wikidata_url(self):
        if self.id:
            return WikidataEntry.WIKIDATA_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['id']
        verbose_name = 'Wikidata entry'
        verbose_name_plural = 'Wikidata entries'
