# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-05-01 22:17
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0006_v0_6_0'),
    ]

    operations = [
        migrations.AddField(
            model_name='wikidataentry',
            name='kind',
            field=models.CharField(blank=True, max_length=1024),
        ),
    ]