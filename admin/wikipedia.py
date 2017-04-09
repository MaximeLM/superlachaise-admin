from django.contrib import admin
from django.utils.html import format_html

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikipediaPage)
class WikipediaPageAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'wikipedia_link', 'default_sort', 'extract_html')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'wikipedia_link']}),
        (None, {'fields': ['default_sort', 'extract', 'extract_html']}),
    ]
    readonly_fields = ('wikipedia_link', 'extract_html')

    def wikipedia_link(self, obj):
        return admin_utils.html_link(obj.wikipedia_url())

    def extract_html(self, obj):
        if obj.extract:
            return format_html(obj.extract)

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'wikipedia_pages', {'ids': ids})
    sync_objects.short_description = 'Sync selected Wikipedia pages'

    actions = [sync_objects]
