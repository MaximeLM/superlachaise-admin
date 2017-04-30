from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id',)
    search_fields = ('id',)

    fieldsets = [
        (None, {'fields': ['id']}),
        (None, {'fields': ['raw_labels']}),
    ]

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'categories', {'ids': ids})
    sync_objects.short_description = 'Sync selected categories'

    actions = [sync_objects]
