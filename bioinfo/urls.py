from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='bioinfo_index'),
    path('load-projects/', views.load_projects, name='bioinfo_load_projects'),
]
