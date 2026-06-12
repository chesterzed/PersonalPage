from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from django.views.generic.base import RedirectView

from wagtail.admin import urls as wagtailadmin_urls
from wagtail import urls as wagtail_urls
from wagtail.documents import urls as wagtaildocs_urls
from personalpage.views import get_project_details, contact_submit

urlpatterns = [
    path(f'{settings.ADMIN_PATH}/', admin.site.urls),
    path(f'{settings.CMS_PATH}/', include(wagtailadmin_urls)),
    path('documents/', include(wagtaildocs_urls)),
    
    # AJAX contact and project details
    path('api/projects/<int:page_id>/details/', get_project_details, name='project_details_ajax'),
    path('api/contact-submit/', contact_submit, name='contact_submit'),
    
    # Redirect root to develop
    path('', RedirectView.as_view(url='/develop/', permanent=False)),
    
    path('develop/', include('develop.urls')),
    path('ml/', include('ml.urls')),
    path('bioinfo/', include('bioinfo.urls')),
    path('printing/', include('printing.urls')),
    
    path('', include(wagtail_urls)),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
