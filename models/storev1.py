import json
from django.db import models

from superlachaise.models import model_validators

class StoreV1NodeIDMapping(models.Model):

    node_id = models.BigIntegerField(primary_key=True, db_index=True)
    wikidata_entry = models.ForeignKey('WikidataEntry', null=True, blank=True, on_delete=models.SET_NULL)

    def __str__(self):
        return str(self.node_id)

    class Meta:
        ordering = ['node_id']
        verbose_name = 'Store V1 node ID mapping'
        verbose_name_plural = 'Store V1 node ID mappings'
