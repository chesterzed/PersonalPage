from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('load-projects/', views.load_projects, name='load_projects'),
]
