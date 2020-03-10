from django import forms
import MySQLdb


class login2(forms.Form):
    usuario = forms.CharField(widget=forms.TextInput,required=True)
    password = forms.CharField(widget=forms.PasswordInput(),required=True)
