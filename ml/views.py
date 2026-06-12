from django.shortcuts import render
from django.http import JsonResponse
from django.template.loader import render_to_string
from django.core.paginator import Paginator
from django.db.models import F
from .models import MLProjectPage

def index(request):
    return render(request, 'ml/index.html')

def load_projects(request):
    page_num = request.GET.get('page', 1)
    projects_list = MLProjectPage.objects.live().order_by(F('release_date').desc(nulls_last=True), '-id')
    paginator = Paginator(projects_list, 2)
    
    try:
        page_obj = paginator.get_page(page_num)
        html = ""
        for project in page_obj:
            # We use a common template for items
            html += render_to_string('projects/project_item.html', {'page': project}, request=request)
            
        return JsonResponse({
            'html': html,
            'has_next': page_obj.has_next()
        })
    except:
        return JsonResponse({'html': '', 'has_next': False})
