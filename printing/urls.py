from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='printing_index'),
    path('load-projects/', views.load_projects, name='printing_load_projects'),
]
