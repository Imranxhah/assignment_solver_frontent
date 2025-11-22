from django.contrib import admin
from .models import AppVersion

@admin.register(AppVersion)
class AppVersionAdmin(admin.ModelAdmin):
    list_display = ('platform', 'version_name', 'version_code', 'force_update', 'created_at')
    list_filter = ('platform', 'force_update')