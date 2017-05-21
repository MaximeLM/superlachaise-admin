from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(StoreV1NodeIDMapping)
class StoreV1NodeIDMappingAdmin(admin.ModelAdmin):
    list_display = ('id', 'wikidata_entry_link',)
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id',]}),
        (None, {'fields': ['wikidata_entry', 'wikidata_entry_link']}),
    ]
    readonly_fields = ('wikidata_entry_link',)

    def wikidata_entry_link(self, obj):
        if obj.wikidata_entry:
            return admin_utils.html_link(admin_utils.change_page_url(obj.wikidata_entry), str(obj.wikidata_entry))
    wikidata_entry_link.admin_order_field = 'wikidata_entry'

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'storev1_node_id_mappings', {'ids': ids})
    sync_objects.short_description = 'Sync selected Store V1 node ID mappings'

    actions = [sync_objects]
