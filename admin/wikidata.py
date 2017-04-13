from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikidataEntry)
class WikidataEntryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'commons_category_link', 'wikidata_link')
    search_fields = ('id', 'name', 'raw_claims')

    fieldsets = [
        (None, {'fields': ['id', 'name', 'wikidata_link', 'secondary_entries', 'wikipedia_pages']}),
        (None, {'fields': ['commons_category', 'commons_category_link']}),
        (None, {'fields': ['raw_labels', 'raw_descriptions', 'raw_claims', 'raw_sitelinks']}),
    ]
    readonly_fields = ('wikidata_link', 'commons_category_link')
    filter_horizontal = ('secondary_entries', 'wikipedia_pages')

    def wikidata_link(self, obj):
        return admin_utils.html_link(obj.wikidata_url())

    def commons_category_link(self, obj):
        if obj.commons_category:
            return admin_utils.html_link(admin_utils.change_page_url(obj.commons_category), str(obj.commons_category))
    commons_category_link.admin_order_field = 'commons_category'

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'wikidata_entries', {'ids': ids})
    sync_objects.short_description = 'Sync selected Wikidata entries'

    actions = [sync_objects]
