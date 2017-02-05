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

    URL_FORMAT = u'https://www.openstreetmap.org/{id}'

    # type and numeric id separeted by /, eg "node/123456"
    id = models.CharField(primary_key=True, db_index=True, max_length=255)

    latitude = models.DecimalField(max_digits=10, default=0, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, default=0, decimal_places=7)

    raw_tags = models.TextField(default='{}', validators=[validate_JSON])

    def tags(self):
        try:
            return json.loads(self.raw_tags)
        except:
            return None

    def openstreetmap_url(self):
        if self.id:
            return OpenStreetMapElement.URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['id']
        verbose_name = 'OpenStreetMap element'
        verbose_name_plural = 'OpenStreetMap elements'
