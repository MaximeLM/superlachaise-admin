import json
from django.db import models
from django.core.exceptions import ValidationError

def validate_JSON(value):
    try:
        json.loads(value)
    except:
        raise ValidationError("Invalid JSON")

class OpenStreetMapElement(models.Model):
    """ An OpenStreetMap element """

    TYPE_CHOICES = (
        ('node', 'node'),
        ('way', 'way'),
        ('relation', 'relation'),
    )

    URL_FORMAT = u'https://www.openstreetmap.org/{type}/{openstreetmap_id}'

    type = models.CharField(db_index=True, max_length=255, choices=TYPE_CHOICES)
    openstreetmap_id = models.BigIntegerField(db_index=True, verbose_name='OpenStreetMap ID')

    latitude = models.DecimalField(max_digits=10, default=0, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, default=0, decimal_places=7)

    raw_tags = models.TextField(default='{}', validators=[validate_JSON])

    def tags(self):
        try:
            return json.loads(self.raw_tags)
        except:
            return None

    def openstreetmap_url(self):
        if self.type and self.openstreetmap_id:
            return OpenStreetMapElement.URL_FORMAT.format(type=self.type, openstreetmap_id=self.openstreetmap_id)

    def __str__(self):
        return "{}:{}".format(self.type, self.openstreetmap_id)

    class Meta:
        unique_together = ('type', 'openstreetmap_id',)
        ordering = ['type', 'openstreetmap_id']
        verbose_name = 'OpenStreetMap element'
        verbose_name_plural = 'OpenStreetMap elements'
