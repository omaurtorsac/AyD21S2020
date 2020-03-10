from django.shortcuts import render, render_to_response
from .forms import login2
from django.http import HttpResponseRedirect
from django.contrib import auth
from django.contrib.auth import login as do_login
from django.contrib.auth.decorators import login_required

import os
import subprocess
import MySQLdb
# Create your views here.

def index(request):
	return render_to_response('inicio/index.html');

@login_required
def adminp(request):
	mensaje="Bienvenido a la pagina del administrador!"
	return render(request,'inicio/adminp.html',{'mensaje':mensaje});

@login_required
def logout(request):
    auth.logout(request)
    return HttpResponseRedirect('../');

@login_required
def adminp(request):
    mensaje="Bienvenido a la pagina del administrador!"
    return render(request,'inicio/adminp.html',{'mensaje':mensaje});

def login(request):
	form = login2(request.POST)
	mensaje = "Hola"
	variables={
		"form":form,
		"mensaje":mensaje,
	}
	if form.is_valid():
		datos = form.cleaned_data
		user = datos.get("usuario")
		psw = datos.get("password")
		usuario = auth.authenticate(username = user, password = psw)
		if usuario is not None:
			do_login(request,usuario)
			auth.login(request, usuario)
			return HttpResponseRedirect('../adminp');
		else:
			mensaje = "Usuario o Password incorrecto"
			variables = {
				"form": form,
				"mensaje": mensaje,
			}
			return render(request, "inicio/login.html", {"form": form, "mensaje": mensaje})   #if user == row[0]:
				#	print("encontro")
				#else
				#return render_to_response('inicio/login.html',{"form":form})
	return render(request, "inicio/login.html", variables)
