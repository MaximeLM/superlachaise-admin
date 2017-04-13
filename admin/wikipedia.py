from django.contrib import admin
from django.utils.html import format_html

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikipediaPage)
class WikipediaPageAdmin(admin.ModelAdmin):
    list_display = ('id', 'default_sort', 'wikipedia_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'wikipedia_link']}),
        (None, {'fields': ['default_sort']}),
    ]
    readonly_fields = ('wikipedia_link',)

    def wikipedia_link(self, obj):
        return admin_utils.html_link(obj.wikipedia_url())

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'wikipedia_pages', {'ids': ids})
    sync_objects.short_description = 'Sync selected Wikipedia pages'

    actions = [sync_objects]
