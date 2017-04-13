from django.contrib import admin
from django.utils.html import format_html

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(CommonsCategory)
class CommonsCategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'default_sort', 'redirect_link', 'image_commons_link', 'commons_link')
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id', 'default_sort', 'commons_link']}),
        (None, {'fields': ['redirect', 'redirect_link']}),
        (None, {'fields': ['image', 'image_commons_link']}),
    ]
    readonly_fields = ('commons_link', 'image_commons_link', 'redirect_link')

    def commons_link(self, obj):
        return admin_utils.html_link(obj.commons_url())

    def image_commons_link(self, obj):
        return admin_utils.html_link(obj.image_commons_url())
    image_commons_link.admin_order_field = 'image'

    def redirect_link(self, obj):
        if obj.redirect:
            return admin_utils.html_link(admin_utils.change_page_url(obj.redirect), str(obj.redirect))
    redirect_link.admin_order_field = 'redirect'

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'commons_categories', {'ids': ids})
    sync_objects.short_description = 'Sync selected Commons categories'

    actions = [sync_objects]