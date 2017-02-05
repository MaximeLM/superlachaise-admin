from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(OpenStreetMapElement)
class OpenStreetMapElementAdmin(admin.ModelAdmin):
    list_display = ('id', 'openstreetmap_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'openstreetmap_link']}),
        (None, {'fields': ['latitude', 'longitude']}),
        (None, {'fields': ['raw_tags']}),
    ]
    readonly_fields = ('openstreetmap_link',)

    def openstreetmap_link(self, obj):
        return admin_utils.html_link(obj.openstreetmap_url())
    openstreetmap_link.allow_tags = True
