from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='ml_index'),
    path('load-projects/', views.load_projects, name='ml_load_projects'),
]
