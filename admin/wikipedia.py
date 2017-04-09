from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikipediaPage)
class WikipediaPageAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'wikipedia_link', 'default_sort', 'extract')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'wikipedia_link']}),
        (None, {'fields': ['default_sort', 'extract']}),
    ]
    readonly_fields = ('wikipedia_link',)

    def wikipedia_link(self, obj):
        return admin_utils.html_link(obj.wikipedia_url())

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'wikipedia_pages', {'ids': ids})
    sync_objects.short_description = 'Sync selected Wikipedia pages'

    actions = [sync_objects]
