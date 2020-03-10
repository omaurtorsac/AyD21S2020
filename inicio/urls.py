from django.urls import path
from django.contrib import admin
from . import views

urlpatterns = [
    path('', views.index),
    path('login/', views.login),
    path('logout/', views.logout),
    path('adminp/',views.adminp),
    #path(r'^adminp2/$','inicio.views.adminp2'),
    #path(r'^registro/$','inicio.views.registrar'),
    #path(r'^reporte1/$','inicio.views.reporte1'),
    #path(r'^reporte2/$','inicio.views.reporte2'),
    #path(r'^reporte3/$','inicio.views.reporte3'),
    #path(r'^reporte4/$','inicio.views.reporte4'),
    #path(r'^reporte5/$','inicio.views.reporte5'),
    #path(r'^reporte6/$','inicio.views.reporte6'),
    #path(r'^cargar/$', 'inicio.views.cargar'),
]
