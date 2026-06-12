from django.shortcuts import get_object_or_404
from wagtail.models import Page
from django.template.loader import render_to_string
from django.http import HttpResponse, JsonResponse
from .forms import ContactForm
from ContactService.telegramAPI import send_telegram_message

def get_project_details(request, page_id):
    # Fetch the specific page instance (DevelopProjectPage, MLProjectPage, etc.)
    page = get_object_or_404(Page, id=page_id).specific
    html = render_to_string('projects/project_detail_ajax.html', {'page': page}, request=request)
    return HttpResponse(html)

def contact_submit(request):
    if request.method == 'POST':
        form = ContactForm(request.POST)
        if form.is_valid():
            name = form.cleaned_data['name']
            email = form.cleaned_data['email']
            message = form.cleaned_data['message']
            
            success = send_telegram_message(name, email, message)
            if success:
                return JsonResponse({'status': 'success', 'message': 'Сообщение успешно отправлено!'})
            else:
                return JsonResponse({'status': 'error', 'message': 'Ошибка при отправке в Telegram.'}, status=500)
        else:
            # Join errors into a single string
            errors = form.errors.as_text()
            return JsonResponse({'status': 'error', 'message': f'Неверные данные: {errors}'}, status=400)
            
    return JsonResponse({'status': 'error', 'message': 'Разрешены только POST-запросы.'}, status=405)
