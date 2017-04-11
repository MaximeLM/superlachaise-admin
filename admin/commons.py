from django.contrib import admin
from django.utils.html import format_html

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(CommonsCategory)
class CommonsCategoryAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'commons_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'commons_link']}),
        (None, {'fields': ['wikitext']}),
    ]
    readonly_fields = ('commons_link',)

    def commons_link(self, obj):
        return admin_utils.html_link(obj.commons_url())

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'commons_categories', {'ids': ids})
    sync_objects.short_description = 'Sync selected Commons categories'

    actions = [sync_objects]
