from django.contrib import admin
import django.core.management

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(OpenStreetMapElement)
class OpenStreetMapElementAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'openstreetmap_link', 'wikidata_entry_link')
    search_fields = ('id', 'name', 'raw_tags')

    fieldsets = [
        (None, {'fields': ['id', 'name', 'openstreetmap_link']}),
        (None, {'fields': ['wikidata_entry', 'wikidata_entry_link']}),
        (None, {'fields': ['latitude', 'longitude', 'raw_tags']}),
    ]
    readonly_fields = ('openstreetmap_link', 'wikidata_entry_link')

    def openstreetmap_link(self, obj):
        return admin_utils.html_link(obj.openstreetmap_url())

    def wikidata_entry_link(self, obj):
        if obj.wikidata_entry:
            return admin_utils.html_link(admin_utils.change_page_url(obj.wikidata_entry), str(obj.wikidata_entry))

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'openstreetmap', {'ids': '|'.join(ids)})
    sync_objects.short_description = 'Sync selected OpenStreetMap elements'

    actions = [sync_objects]
