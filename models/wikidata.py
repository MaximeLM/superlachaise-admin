import json
import datetime
import time
import logging
from django.db import models
import dateutil.parser

from superlachaise.models import model_validators

logger = logging.getLogger("superlachaise")

class WikidataEntry(models.Model):

    # Q<numeric_id>
    id = models.CharField(primary_key=True, db_index=True, max_length=1024, validators=[model_validators.validate_wikidata_id])

    name = models.CharField(max_length=1024, blank=True)

    raw_labels = models.TextField(default='{}', validators=[model_validators.validate_JSON])
    raw_descriptions = models.TextField(default='{}', validators=[model_validators.validate_JSON])
    raw_claims = models.TextField(default='{}', validators=[model_validators.validate_JSON])
    raw_sitelinks = models.TextField(default='{}', validators=[model_validators.validate_JSON])

    secondary_entries = models.ManyToManyField('self', blank=True, symmetrical=False)
    wikipedia_pages = models.ManyToManyField('WikipediaPage', blank=True)
    commons_category = models.ForeignKey('CommonsCategory', null=True, blank=True, on_delete=models.SET_NULL)
    wikidata_categories = models.ManyToManyField('WikidataCategory', blank=True)

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

    def get_sitelink(self, site):
        sitelinks = self.sitelinks()
        if sitelinks and site in sitelinks and 'title' in sitelinks[site]:
            return sitelinks[site]['title']

    def get_wikipedia_page(self, language, follow_redirects=True):
        for wikipedia_page in self.wikipedia_pages.filter(id__startswith=language):
            if follow_redirects:
                while wikipedia_page.redirect:
                    wikipedia_page = wikipedia_page.redirect
            return wikipedia_page

    def get_commons_category(self, follow_redirects=True):
        commons_category = self.commons_category
        if follow_redirects:
            while commons_category and commons_category.redirect:
                commons_category = commons_category.redirect
        return commons_category

    def get_default_sort(self, language):
        # Use default sort from wikipedia page if available
        wikipedia_page = self.get_wikipedia_page(language)
        if wikipedia_page and wikipedia_page.default_sort:
            return wikipedia_page.default_sort
        # Use default sort from commons category if available
        commons_category = self.get_commons_category()
        if commons_category and commons_category.default_sort:
            return commons_category.default_sort
        # Use label
        return self.get_label(language)

    def get_categories(self):
        return [wikidata_category.category for wikidata_category in self.wikidata_categories.all() if wikidata_category.category]

    # Claims utils

    P_INSTANCE_OF = "P31"

    F_MAINSNAK = "mainsnak"
    F_QUALIFIERS = "qualifiers"

    def get_property_value(self, property_dict):
        if 'datavalue' in property_dict and 'value' in property_dict['datavalue']:
            return property_dict['datavalue']['value']

    def get_property_id(self, property_dict):
        value = self.get_property_value(property_dict)
        if value and 'id' in value:
            return value['id']

    def get_instance_of_ids(self, claims):
        instance_of_ids = []
        if claims and WikidataEntry.P_INSTANCE_OF in claims:
            for instance_of in claims[WikidataEntry.P_INSTANCE_OF]:
                if WikidataEntry.F_MAINSNAK in instance_of:
                    instance_of_id = self.get_property_id(instance_of[WikidataEntry.F_MAINSNAK])
                    if instance_of_id:
                        instance_of_ids.append(instance_of_id)
        return instance_of_ids

    def get_date_dict(self, claims, claim):
        if claim in claims:
            # Take the date with the highest precision
            best_date_value = None
            for date_claim in claims[claim]:
                if WikidataEntry.F_MAINSNAK in date_claim:
                    date_value = self.get_property_value(date_claim[WikidataEntry.F_MAINSNAK])
                    if not best_date_value or best_date_value['precision'] < date_value['precision']:
                        best_date_value = date_value

            if best_date_value:
                date_string = best_date_value['time']
                precision_int = best_date_value['precision']

                date = datetime.date(*time.strptime(date_string[1:11], "%Y-%m-%d")[:3])
                date_dict = {
                    "year": None,
                    "month": None,
                    "day": None,
                    "precision": None,
                }
                precision = None
                if precision_int >= 9:
                    date_dict["precision"] = "year"
                    date_dict["year"] = date.year
                if precision_int >= 10:
                    date_dict["precision"] = "month"
                    date_dict["month"] = date.month
                if precision_int >= 11:
                    date_dict["precision"] = "day"
                    date_dict["day"] = date.day
                if "precision" in date_dict:
                    return date_dict
                else:
                    logger.warning("Unsupported date precision {} for Wikidata entry {}".format(precision_int, self))

    WIKIDATA_URL_FORMAT = "https://www.wikidata.org/wiki/{id}"
    def wikidata_url(self):
        if self.id:
            return WikidataEntry.WIKIDATA_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id + ((" - " + self.name) if self.name else "")

    class Meta:
        ordering = ['id']
        verbose_name = 'Wikidata entry'
        verbose_name_plural = 'Wikidata entries'

class WikidataCategory(models.Model):

    # <kind>/Q<numeric_id>
    id = models.CharField(primary_key=True, db_index=True, max_length=1024, validators=[model_validators.validate_wikidata_category_id])
    name = models.CharField(max_length=1024, blank=True)

    raw_labels = models.TextField(default='{}', validators=[model_validators.validate_JSON])

    category = models.ForeignKey('Category', null=True, blank=True, on_delete=models.SET_NULL, related_name="wikidata_categories")

    # JSON fields

    def labels(self):
        if self.raw_labels:
            return json.loads(self.raw_labels)

    # Fields access

    def wikidata_id(self):
        if self.id:
            split_id = self.id.split('/')
            if len(split_id) == 2:
                return split_id[1]

    def get_label(self, language):
        labels = self.labels()
        if labels and language in labels and 'value' in labels[language]:
            return labels[language]['value']

    WIKIDATA_URL_FORMAT = "https://www.wikidata.org/wiki/{id}"
    def wikidata_url(self):
        wikidata_id = self.wikidata_id()
        if wikidata_id:
            return WikidataCategory.WIKIDATA_URL_FORMAT.format(id=wikidata_id)

    def __str__(self):
        return self.id + ((" - " + self.name) if self.name else "")

    class Meta:
        ordering = ['id']
        verbose_name = 'Wikidata category'
        verbose_name_plural = 'Wikidata categories'
