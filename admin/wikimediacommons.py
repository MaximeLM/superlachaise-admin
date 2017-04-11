from django.contrib import admin
from django.utils.html import format_html

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikimediacommonsCategory)
class WikimediacommonsCategoryAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'wikimediacommons_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'wikimediacommons_link']}),
        (None, {'fields': ['wikitext']}),
    ]
    readonly_fields = ('wikimediacommons_link',)

    def wikimediacommons_link(self, obj):
        return admin_utils.html_link(obj.wikimediacommons_url())

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'wikimediacommons_categories', {'ids': ids})
    sync_objects.short_description = 'Sync selected Wikipedia pages'

    actions = [sync_objects]
