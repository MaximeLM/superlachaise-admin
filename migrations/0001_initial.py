# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-04-08 18:10
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion
import superlachaise.models.model_validators


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='OpenstreetmapElement',
            fields=[
                ('id', models.CharField(db_index=True, max_length=255, primary_key=True, serialize=False, validators=[superlachaise.models.model_validators.validate_openstreetmap_id])),
                ('name', models.CharField(blank=True, max_length=255)),
                ('latitude', models.DecimalField(decimal_places=7, default=0, max_digits=10)),
                ('longitude', models.DecimalField(decimal_places=7, default=0, max_digits=10)),
                ('raw_tags', models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON])),
            ],
            options={
                'verbose_name': 'Openstreetmap element',
                'verbose_name_plural': 'Openstreetmap elements',
                'ordering': ['id'],
            },
        ),
        migrations.CreateModel(
            name='WikidataEntry',
            fields=[
                ('id', models.CharField(db_index=True, max_length=255, primary_key=True, serialize=False, validators=[superlachaise.models.model_validators.validate_wikidata_id])),
                ('name', models.CharField(blank=True, max_length=255)),
                ('raw_labels', models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON])),
                ('raw_descriptions', models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON])),
                ('raw_claims', models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON])),
                ('raw_sitelinks', models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON])),
                ('secondary_entries', models.ManyToManyField(blank=True, to='superlachaise.WikidataEntry')),
            ],
            options={
                'verbose_name': 'Wikidata entry',
                'verbose_name_plural': 'Wikidata entries',
                'ordering': ['id'],
            },
        ),
        migrations.AddField(
            model_name='openstreetmapelement',
            name='wikidata_entry',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='superlachaise.WikidataEntry'),
        ),
    ]
