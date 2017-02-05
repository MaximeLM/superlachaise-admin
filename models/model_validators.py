import json
from json.decoder import JSONDecodeError
from django.core.exceptions import ValidationError

def validate_JSON(value):
    try:
        json.loads(value)
    except JSONDecodeError as e:
        raise ValidationError("Invalid JSON: {}".format(str(e)))

def validate_openstreetmap_id(value):
    if len(value.split('/')) != 2:
        raise ValidationError("OpenStreetMap ID must have the format <type>/<numeric_id>")
