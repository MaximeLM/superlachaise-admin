from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikipediaPage)
class WikipediaPageAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'wikipedia_link', 'wikidata_entry_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'wikipedia_link']}),
        (None, {'fields': ['wikidata_entry', 'wikidata_entry_link']}),
        (None, {'fields': ['default_sort', 'extract']}),
    ]
    readonly_fields = ('wikipedia_link', 'wikidata_entry_link')

    def wikipedia_link(self, obj):
        return admin_utils.html_link(obj.wikipedia_url())

    def wikidata_entry_link(self, obj):
        if obj.wikidata_entry:
            return admin_utils.html_link(admin_utils.change_page_url(obj.wikidata_entry), str(obj.wikidata_entry))

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'wikipedia', {'ids': '|'.join(ids)})
    sync_objects.short_description = 'Sync selected Wikipedia pages'

    actions = [sync_objects]
