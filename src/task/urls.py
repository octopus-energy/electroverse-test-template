from django.urls import path

from src.task import views

urlpatterns = [
    path("", views.index, name="index"),
]
