from django.contrib import admin
from django.utils.html import format_html

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(CommonsCategory)
class CommonsCategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'default_sort', 'main_commons_file_link', 'redirect_link', 'commons_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'commons_link']}),
        (None, {'fields': ['main_commons_file', 'main_commons_file_link', 'commons_files']}),
        (None, {'fields': ['redirect', 'redirect_link']}),
        (None, {'fields': ['image', 'default_sort']}),
    ]
    readonly_fields = ('commons_link', 'main_commons_file_link', 'redirect_link')
    filter_horizontal = ('commons_files',)

    def commons_link(self, obj):
        return admin_utils.html_link(obj.commons_url())

    def main_commons_file_link(self, obj):
        if obj.main_commons_file:
            return admin_utils.html_link(admin_utils.change_page_url(obj.main_commons_file), str(obj.main_commons_file))
    main_commons_file_link.admin_order_field = 'main_commons_file'

    def redirect_link(self, obj):
        if obj.redirect:
            return admin_utils.html_link(admin_utils.change_page_url(obj.redirect), str(obj.redirect))
    redirect_link.admin_order_field = 'redirect'

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'commons_categories', {'ids': ids})
    sync_objects.short_description = 'Sync selected Commons categories'

    actions = [sync_objects]

@admin.register(CommonsFile)
class CommonsFileAdmin(admin.ModelAdmin):
    list_display = ('id', 'license', 'author', 'commons_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'commons_link']}),
        (None, {'fields': ['license', 'author']}),
    ]
    readonly_fields = ('commons_link',)

    def commons_link(self, obj):
        return admin_utils.html_link(obj.commons_url())

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'commons_files', {'ids': ids})
    sync_objects.short_description = 'Sync selected Commons files'

    actions = [sync_objects]
