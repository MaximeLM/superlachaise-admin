# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-05-02 08:52
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0008_auto_20170502_0050'),
    ]

    operations = [
        migrations.AlterField(
            model_name='openstreetmapelement',
            name='wikidata_entry',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='openstreetmap_elements', to='superlachaise.WikidataEntry'),
        ),
    ]
