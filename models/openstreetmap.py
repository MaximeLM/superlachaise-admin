import json
from django.db import models

from superlachaise.models import model_validators

class OpenstreetmapElement(models.Model):

    # type and numeric id separeted by /, eg "node/123456"
    id = models.CharField(primary_key=True, db_index=True, max_length=1024, validators=[model_validators.validate_openstreetmap_id])

    element_type = models.CharField(blank=True, max_length=1024)
    numeric_id = models.BigIntegerField(blank=True, null=True)

    name = models.CharField(blank=True, max_length=1024)
    latitude = models.DecimalField(max_digits=10, default=0, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, default=0, decimal_places=7)
    raw_tags = models.TextField(default='{}', validators=[model_validators.validate_JSON])
    wikidata_entry = models.ForeignKey('WikidataEntry', null=True, blank=True, on_delete=models.SET_NULL, related_name="openstreetmap_elements")

    def tags(self):
        if self.raw_tags:
            return json.loads(self.raw_tags)

    OPENSTREETMAP_URL_FORMAT = "https://www.openstreetmap.org/{id}"
    def openstreetmap_url(self):
        if self.id:
            return OpenstreetmapElement.OPENSTREETMAP_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id + ((" - " + self.name) if self.name else "")

    class Meta:
        ordering = ['id']
        verbose_name = 'Openstreetmap element'
        verbose_name_plural = 'Openstreetmap elements'
