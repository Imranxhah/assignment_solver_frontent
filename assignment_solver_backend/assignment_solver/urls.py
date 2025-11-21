from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Custom auth endpoints
    path('auth/', include('custom_auth.urls')),
    
    # Other app endpoints
    path('api/submissions/', include('submissions.urls')),
    path('api/assignments/', include('assignments.urls')),
]

# Media files (for development)
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
