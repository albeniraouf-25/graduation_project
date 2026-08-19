from django.urls import path
from .views import *


urlpatterns = [
   path('create/', CreateAccount.as_view(), name="create_user"),
   path('verify_email/', VerifyEmail.as_view(), name="verify_email"),
   path('resend_verification/', ResendVerificationCode.as_view(), name="resend-verification"),
   path('login/', Login.as_view(), name="login"),
   path('view_profile/', ViewProfile.as_view(), name="view_profile"),
   path('view_profile/<int:user_id>/', ViewProfileUser.as_view(), name= "view_p"),
   path('update_driver_profile/', UpdateDriverProfile.as_view(), name="update_driver_profile"),
   path('update_rider_profile/', UpdateRiderProfile.as_view(), name="update_rider_profile"),
   path('logout/', Logout.as_view(), name= "logout"),
   path('forgot_password/', ForgotPasswordView.as_view(), name= 'forgot_password'),
   path('verify_reset_code/', VerifyResetCodeView.as_view(), name= 'verify_reset_code'),
   path('reset_password/', ResetPassword.as_view(), name= 'reset_password'),
   path('resend_reset_code/', ResendResetCodeView.as_view(), name='resend_reset_code'),
   ]