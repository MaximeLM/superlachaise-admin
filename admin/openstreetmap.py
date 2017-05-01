from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(OpenstreetmapElement)
class OpenstreetmapElementAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'wikidata_entry_link', 'openstreetmap_link')
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
    wikidata_entry_link.admin_order_field = 'wikidata_entry'

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'openstreetmap_elements', {'ids': (ids)})
    sync_objects.short_description = 'Sync selected Openstreetmap elements'

    actions = [sync_objects]
