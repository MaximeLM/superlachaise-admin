import json
import re
from json.decoder import JSONDecodeError
from django.core.exceptions import ValidationError

def validate_JSON(value):
    try:
        json.loads(value)
    except JSONDecodeError as e:
        raise ValidationError("Invalid JSON: {}".format(str(e)))

def validate_openstreetmap_id(value):
    if len(value.split('/')) != 2:
        raise ValidationError("Invalid Openstreetmap ID: expected <type>/<numeric_id>")

WIKIDATA_ID_PATTERN = re.compile("^Q([0-9])+$")
def validate_wikidata_id(value):
    if not WIKIDATA_ID_PATTERN.match(value):
        raise ValidationError("Invalid Wikidata ID: expected Q<numeric_id>")
