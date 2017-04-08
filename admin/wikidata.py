from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikidataEntry)
class WikidataEntryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')
    search_fields = ('id', 'name')

    fieldsets = [
        (None, {'fields': ['id', 'name', 'wikidata_link', 'secondary_entries']}),
        (None, {'fields': ['raw_labels', 'raw_descriptions', 'raw_claims', 'raw_sitelinks']}),
    ]
    readonly_fields = ('wikidata_link',)
    filter_horizontal = ('secondary_entries',)

    def wikidata_link(self, obj):
        return admin_utils.html_link(obj.wikidata_url())
    wikidata_link.allow_tags = True
