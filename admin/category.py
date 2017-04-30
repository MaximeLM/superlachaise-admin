from django.contrib import admin

from superlachaise.models import *
from superlachaise.admin import admin_utils

class WikidataCategoryInline(admin.StackedInline):
    model = WikidataCategory
    extra = 0

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'kind')
    search_fields = ('id', 'kind')

    fieldsets = [
        (None, {'fields': ['id', 'kind']}),
        (None, {'fields': ['raw_labels']}),
    ]

    inlines = [
            WikidataCategoryInline,
        ]

    def sync_objects(self, request, queryset):
        ids = [object.id for object in queryset]
        admin_utils.sync(request, 'categories', {'ids': ids})
    sync_objects.short_description = 'Sync selected categories'

    actions = [sync_objects]
