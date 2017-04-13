# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-04-13 17:55
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0003_auto_20170413_1944'),
    ]

    operations = [
        migrations.AddField(
            model_name='commonscategory',
            name='commons_files',
            field=models.ManyToManyField(blank=True, related_name='file_of', to='superlachaise.CommonsFile'),
        ),
        migrations.AddField(
            model_name='commonscategory',
            name='main_commons_file',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='main_file_of', to='superlachaise.CommonsFile'),
        ),
    ]
