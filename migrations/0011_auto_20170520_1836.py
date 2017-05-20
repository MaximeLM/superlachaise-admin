# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-05-20 16:36
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('superlachaise', '0010_auto_20170520_1825'),
    ]

    operations = [
        migrations.CreateModel(
            name='CommonsFile',
            fields=[
                ('id', models.CharField(db_index=True, max_length=1024, primary_key=True, serialize=False)),
                ('author', models.CharField(blank=True, default='', max_length=1024)),
                ('license', models.CharField(blank=True, default='', max_length=1024)),
                ('image_url', models.TextField(blank=True, default='')),
                ('thumbnail_url_template', models.TextField(blank=True, default='')),
            ],
        ),
        migrations.AddField(
            model_name='commonscategory',
            name='commons_files',
            field=models.ManyToManyField(blank=True, related_name='commons_categories', to='superlachaise.CommonsFile'),
        ),
        migrations.AddField(
            model_name='commonscategory',
            name='main_commons_file',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='superlachaise.CommonsFile'),
        ),
    ]
