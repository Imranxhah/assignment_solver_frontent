from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.register, name='register'),
    path('login/', views.login, name='login'),
    path('verify-email/', views.verify_email, name='verify-email'),
    path('forgot-password/', views.forgot_password, name='forgot-password'),
    path('reset-password/', views.reset_password, name='reset-password'),
    path('change-password/', views.change_password, name='change-password'),
    path('complete-profile/', views.complete_profile, name='complete-profile'),
    path('user/', views.get_user_info, name='get-user-info'),
    path('send-verification-email/', views.send_verification_email_view, name='send-verification-email'),
]
