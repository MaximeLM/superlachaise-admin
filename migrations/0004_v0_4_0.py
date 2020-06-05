# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-04-30 14:15
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion
import superlachaise.models.model_validators


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0003_v0_3_0'),
    ]

    operations = [
        migrations.CreateModel(
            name='Category',
            fields=[
                ('id', models.CharField(db_index=True, max_length=1024, primary_key=True, serialize=False)),
                ('kind', models.CharField(blank=True, max_length=1024)),
                ('raw_labels', models.TextField(default='{}', validators=[superlachaise.models.model_validators.validate_JSON])),
            ],
            options={
                'verbose_name': 'Category',
                'verbose_name_plural': 'Categories',
                'ordering': ['id'],
            },
        ),
        migrations.AlterField(
            model_name='wikidatacategory',
            name='id',
            field=models.CharField(db_index=True, max_length=1024, primary_key=True, serialize=False, validators=[superlachaise.models.model_validators.validate_wikidata_category_id]),
        ),
        migrations.AddField(
            model_name='wikidatacategory',
            name='category',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='wikidata_categories', to='superlachaise.Category'),
        ),
    ]