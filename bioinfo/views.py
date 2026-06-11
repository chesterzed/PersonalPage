from django.shortcuts import render
from django.http import JsonResponse
from django.template.loader import render_to_string
from django.core.paginator import Paginator
from .models import BioinfoProjectPage

def index(request):
    return render(request, 'bioinfo/index.html')

def load_projects(request):
    page_num = request.GET.get('page', 1)
    projects_list = BioinfoProjectPage.objects.live().order_by('-id')
    paginator = Paginator(projects_list, 2)
    
    try:
        page_obj = paginator.get_page(page_num)
        html = ""
        for project in page_obj:
            html += render_to_string('projects/project_item.html', {'page': project}, request=request)
            
        return JsonResponse({
            'html': html,
            'has_next': page_obj.has_next()
        })
    except:
        return JsonResponse({'html': '', 'has_next': False})
