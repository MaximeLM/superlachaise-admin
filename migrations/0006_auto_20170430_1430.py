# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-04-30 12:30
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0005_auto_20170430_1428'),
    ]

    operations = [
        migrations.AlterField(
            model_name='category',
            name='id',
            field=models.CharField(db_index=True, max_length=1024, primary_key=True, serialize=False),
        ),
    ]
