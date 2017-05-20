from django.contrib import admin
from django.utils.html import format_html

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(WikipediaPage)
class WikipediaPageAdmin(admin.ModelAdmin):
    list_display = ('id', 'default_sort', 'extract_html', 'redirect_link', 'wikipedia_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'wikipedia_link']}),
        (None, {'fields': ['default_sort', 'extract', 'extract_html']}),
        (None, {'fields': ['redirect', 'redirect_link']}),
    ]
    readonly_fields = ('wikipedia_link', 'extract_html', 'redirect_link')

    def wikipedia_link(self, obj):
        return admin_utils.html_link(obj.wikipedia_url())

    def extract_html(self, obj):
        if obj.extract:
            return format_html(obj.extract)
    extract_html.admin_order_field = 'extract'

    def redirect_link(self, obj):
        if obj.redirect:
            return admin_utils.html_link(admin_utils.change_page_url(obj.redirect), str(obj.redirect))
    redirect_link.admin_order_field = 'redirect'

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'wikipedia_pages', {'ids': ids})
    sync_objects.short_description = 'Sync selected Wikipedia pages'

    actions = [sync_objects]
