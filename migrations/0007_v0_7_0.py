# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-05-03 05:13
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0006_v0_6_0'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='wikidataentry',
            name='secondary_entries',
        ),
        migrations.AddField(
            model_name='wikidataentry',
            name='kind',
            field=models.CharField(blank=True, max_length=1024),
        ),
        migrations.AddField(
            model_name='wikidataentry',
            name='secondary_wikidata_entries',
            field=models.ManyToManyField(blank=True, related_name='primary_wikidata_entries', to='superlachaise.WikidataEntry'),
        ),
        migrations.AlterField(
            model_name='openstreetmapelement',
            name='wikidata_entry',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='openstreetmap_elements', to='superlachaise.WikidataEntry'),
        ),
    ]
