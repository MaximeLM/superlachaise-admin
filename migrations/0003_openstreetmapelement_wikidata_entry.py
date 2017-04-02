# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-04-01 17:09
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0002_wikidataentry'),
    ]

    operations = [
        migrations.AddField(
            model_name='openstreetmapelement',
            name='wikidata_entry',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='superlachaise.WikidataEntry'),
        ),
    ]
