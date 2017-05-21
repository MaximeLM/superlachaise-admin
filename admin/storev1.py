from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(StoreV1NodeIDMapping)
class StoreV1NodeIDMappingAdmin(admin.ModelAdmin):
    list_display = ('node_id', 'wikidata_entry_link',)
    search_fields = ('node_id',)

    fieldsets = [
        (None, {'fields': ['node_id',]}),
        (None, {'fields': ['wikidata_entry', 'wikidata_entry_link']}),
    ]
    readonly_fields = ('wikidata_entry_link',)

    def wikidata_entry_link(self, obj):
        if obj.wikidata_entry:
            return admin_utils.html_link(admin_utils.change_page_url(obj.wikidata_entry), str(obj.wikidata_entry))
    wikidata_entry_link.admin_order_field = 'wikidata_entry'
