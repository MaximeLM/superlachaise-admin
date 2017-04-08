# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-04-08 10:09
from __future__ import unicode_literals

from django.db import migrations, models
import superlachaise.models.model_validators


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0003_openstreetmapelement_wikidata_entry'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='wikidataentry',
            name='raw_json',
        ),
        migrations.AddField(
            model_name='wikidataentry',
            name='raw_claims',
            field=models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON]),
        ),
        migrations.AddField(
            model_name='wikidataentry',
            name='raw_descriptions',
            field=models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON]),
        ),
        migrations.AddField(
            model_name='wikidataentry',
            name='raw_labels',
            field=models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON]),
        ),
        migrations.AddField(
            model_name='wikidataentry',
            name='raw_sitelinks',
            field=models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON]),
        ),
    ]