from django.shortcuts import get_object_or_404
from wagtail.models import Page
from django.template.loader import render_to_string
from django.http import HttpResponse

def get_project_details(request, page_id):
    # Fetch the specific page instance (DevelopProjectPage, MLProjectPage, etc.)
    page = get_object_or_404(Page, id=page_id).specific
    html = render_to_string('projects/project_detail_ajax.html', {'page': page}, request=request)
    return HttpResponse(html)
