from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin.utils import AdminUtils

@admin.register(OpenStreetMapElement)
class OpenStreetMapElementAdmin(admin.ModelAdmin):
    list_display = ('type', 'openstreetmap_id', 'openstreetmap_link')
    list_filter = ('type',)
    search_fields = ('type', 'openstreetmap_id',)

    fieldsets = [
        (None, {'fields': ['type', 'openstreetmap_id', 'openstreetmap_link']}),
        (None, {'fields': ['latitude', 'longitude']}),
        (None, {'fields': ['raw_tags']}),
    ]
    readonly_fields = ('openstreetmap_link',)

    def openstreetmap_link(self, obj):
        return AdminUtils.html_link(obj.openstreetmap_url())
    openstreetmap_link.allow_tags = True
