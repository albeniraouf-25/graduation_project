from datetime import timedelta
import secrets
from django.utils import timezone
import email
from random import randint
from django.core.mail import send_mail
from django.db import transaction
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.response import Response  
from .serializers import *
from rest_framework import permissions
from .models import  *
import requests
from django.conf import settings
from requests.auth import HTTPBasicAuth
from oauth2_provider.models import  RefreshToken

class CreateAccount(APIView):
    permission_classes = [permissions.AllowAny]
    @transaction.atomic
    def post(self, request):
        reg_serializer = RegistrationSerializer(data=request.data)

        if reg_serializer.is_valid():
            try:
                new_user = reg_serializer.save() 
                if new_user.user_type == "admin":

                    return Response(
                        {
                            "message": "Admin account created successfully.",
                            "user": {
                                "email": new_user.email,
                                "name": new_user.name,
                                "user_type": new_user.user_type
                            }
                        },
                        status=status.HTTP_201_CREATED
                    )

                code = str(randint(100000,999999))
                EmailVerification.objects.update_or_create(
                    user=new_user,
                    defaults={
                        "code": code,
                        "expires_at": timezone.now() + timedelta(minutes=10)
                    }
                )

                send_mail(
                    subject="Verify your email",
                    message=f"""
                        Welcome to Atareeqak.
                        Your verification code is:
                        {code}
                        This code will expire in 10 minutes.
                    """,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[new_user.email],
                    fail_silently=False
                )

                return Response(
                    {
                        "message": "Account created successfully. Please check your email for the verification code.",
                        "email": new_user.email
                    },
                    status=status.HTTP_201_CREATED
                )
            except Exception:
                return Response(
                    {
                        "error": (
                            "Account creation failed. "
                            "Please try again."
                        )
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
        return Response(
            reg_serializer.errors,
            status=400
        )

class VerifyEmail(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):

        serializer = VerifyEmailSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        email = serializer.validated_data["email"]
        code = serializer.validated_data["code"]

        try:
            user = MainUser.objects.get(email=email)

            verification = EmailVerification.objects.get(user=user)

        except (MainUser.DoesNotExist, EmailVerification.DoesNotExist):

            return Response(
                {
                    "error": "Verification request not found."
                },
                status=404
            )

        if verification.expires_at < timezone.now():

            return Response(
                {
                    "error": "Verification code expired."
                },
                status=400
            )

        if verification.code != code:

            return Response(
                {
                    "error": "Invalid verification code."
                },
                status=400
            )

        verification.delete()

        return Response(
            {
                "message": "Email verified successfully."
            },
            status=200
        )


class ResendVerificationCode(APIView):
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        serializer = ResendVerificationSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )

        email = serializer.validated_data["email"]
        try:
            user = MainUser.objects.get(email=email)
        except MainUser.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )
        try:
            verification = user.email_verification
        except EmailVerification.DoesNotExist:
            return Response(
                {"error": "Email is already verified."},
                status=status.HTTP_400_BAD_REQUEST
            )

        code = str(randint(100000, 999999))

        verification.code = code
        verification.expires_at = timezone.now() + timedelta(minutes=10)
        verification.save()

        send_mail(
            subject="A tareeqak Email Verification",
            message=f"""
            Welcome to A tareeqak.
            Your new verification code is:
            {code}
            This code will expire in 10 minutes.
            """,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False,
        )

        return Response(
            {
                "message": "A new verification code has been sent to your email."
            },
            status=status.HTTP_200_OK
        )


class Login(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        log_serializer = LoginSerializer(data=request.data)

        if not log_serializer.is_valid():
            return Response(
                log_serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )

        email = log_serializer.validated_data["email"]
        password = log_serializer.validated_data["password"]

        try:
            user = MainUser.objects.get(email=email)
            if EmailVerification.objects.filter(user=user).exists():
                return Response(
                    {
                        "error": "Please verify your email first."
                    },
                    status=status.HTTP_403_FORBIDDEN
                )

            if not user.is_active:
                return Response(
                    {"error": "Your account has been blocked."},
                    status=status.HTTP_403_FORBIDDEN
                )

        except MainUser.DoesNotExist:
            pass

        client_id = getattr(settings, "OAUTH_CLIENT_ID", None)
        client_secret = getattr(settings, "OAUTH_CLIENT_SECRET", None)
        token_url = getattr(settings,"OAUTH_TOKEN_URL", "http://127.0.0.1:8000/auth/token/")

        try:
            resp = requests.post(
                token_url,
                data={
                    "grant_type": "password",
                    "username": email,
                    "password": password,
                },
                auth=HTTPBasicAuth(client_id, client_secret),
                timeout=5,
            )

        except requests.RequestException as e:
            return Response(
                {
                    "detail": "Token server error",
                    "error": str(e),
                },
                status=status.HTTP_502_BAD_GATEWAY,
            )

        if resp.status_code != 200:
            try:
                return Response(resp.json(), status=resp.status_code)
            except ValueError:
                return Response(
                    {
                        "detail": "Token server returned an error",
                        "body": resp.text,
                    },
                    status=resp.status_code,
                )

        token_data = resp.json()

        try:
            user = MainUser.objects.get(email=email)
            token_data["user"] = {
                "email": user.email,
                "name": user.name,
                "user_type": user.user_type,
            }
        except MainUser.DoesNotExist:
            token_data["user"] = {
                "email": email,
            }

        return Response(token_data, status=status.HTTP_200_OK)

class ForgotPasswordView(APIView):
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        email = serializer.validated_data["email"]

        try:
            user = MainUser.objects.get(email=email)
        except MainUser.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )
        PasswordResetCode.objects.filter(user=user).delete()
        code = str(randint(100000, 999999))
        reset_token = secrets.token_urlsafe(32)
        PasswordResetCode.objects.update_or_create(
            user=user,
            reset_token=reset_token,
            defaults={
                "code": code,
                "expires_at": timezone.now() + timedelta(minutes=10)
            }
        )
        send_mail(
            subject="Atareeqak Password Reset",
            message=f"""
                Hello {user.name or ''},
                Your password reset code is:
                {code}
                This code will expire in 10 minutes.
                If you did not request a password reset, please ignore this email.
            """,    
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False
        )
        return Response(
            {
                "message": "Password reset code sent successfully.",
                "email": user.email,
                "reset_token": reset_token
            },
            status=status.HTTP_200_OK
        )

class VerifyResetCodeView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = VerifyResetCodeSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        reset_token = serializer.validated_data["reset_token"]
        code = serializer.validated_data["code"]

        try:
            reset = PasswordResetCode.objects.get(
                reset_token=reset_token
            )
        except PasswordResetCode.DoesNotExist:
            return Response(
                {"error": "Invalid reset request."},
                status=status.HTTP_404_NOT_FOUND
            )
        if reset.expires_at < timezone.now():
            reset.delete()

            return Response(
                {"error": "Verification code expired."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if reset.code != code:
            return Response(
                {"error": "Invalid verification code."},
                status=status.HTTP_400_BAD_REQUEST
            )

        reset.is_verified = True
        reset.save()

        return Response(
            {
                "message": "Verification code verified successfully."
            },
            status=status.HTTP_200_OK
        )

class ResendResetCodeView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ResendResetCodeSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )

        reset_token = serializer.validated_data["reset_token"]

        try:
            reset = PasswordResetCode.objects.select_related("user").get(
                reset_token=reset_token
            )
        except PasswordResetCode.DoesNotExist:
            return Response(
                {"error": "Invalid reset request."},
                status=status.HTTP_404_NOT_FOUND
            )

        if reset.expires_at < timezone.now():
            reset.delete()
            return Response(
                {"error": "Reset request expired. Please request a new reset code."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = reset.user

        code = str(randint(100000, 999999))

        reset.code = code
        reset.expires_at = timezone.now() + timedelta(minutes=10)
        reset.is_verified = False
        reset.save()

        send_mail(
            subject="Atareeqak Password Reset",
            message=f"""
                Hello {user.name or ''},
                Your new password reset code is:
                {code}
                This code will expire in 10 minutes.
                If you did not request a password reset, please ignore this email.
            """,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False
        )

        return Response(
            {
                "message": "A new password reset code has been sent.",
            },
            status=status.HTTP_200_OK
        )


class ResetPassword(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        reset_token = serializer.validated_data["reset_token"]
        new_password = serializer.validated_data["new_password"]

        try:
            reset = PasswordResetCode.objects.get(
                reset_token=reset_token
            )
        except PasswordResetCode.DoesNotExist:
            return Response(
                {"error": "Invalid reset request."},
                status=status.HTTP_404_NOT_FOUND
            )
        if reset.expires_at < timezone.now():
            reset.delete()

            return Response(
                {"error": "Reset request expired."},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not reset.is_verified:
            return Response(
                {
                    "error": "Please verify the reset code first."
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        user = reset.user
        user.set_password(new_password)
        user.save()
        reset.delete()
        return Response(
            {
                "message": "Password reset successfully."
            },
            status=status.HTTP_200_OK
        )
            
class Logout(APIView):

    def post(self, request):
        try:
            token = request.auth  

            if token:
                RefreshToken.objects.filter(access_token=token).delete()
                token.delete()
                return Response({"detail": "Successfully logged out."}, status=status.HTTP_200_OK)
            else:
                return Response({"detail": "Token not found."}, status=status.HTTP_400_BAD_REQUEST)
        
        except Exception as e:
            return Response({"detail": "Error during logout", "error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ViewProfile(APIView):

    def get(self, request):
        user = request.user

        if user.user_type == "driver":
            try:
                driver = user.driver
                serializer = DriverProfileSerializer(driver)
            except Driver.DoesNotExist:
                return Response({"error": "Driver profile not found"}, status=status.HTTP_404_NOT_FOUND)

        elif user.user_type == "rider":
            try:
                rider = user.rider
                serializer = RiderProfileSerializer(rider)
            except Rider.DoesNotExist:
                return Response({"error": "Rider profile not found"}, status=status.HTTP_404_NOT_FOUND)

        else:
            return Response({"error": "Invalid user type"}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.data, status=status.HTTP_200_OK)


class ViewProfileUser(APIView):

    def get(self, request, user_id):
        try:
            user = MainUser.objects.get(id=user_id)
        except MainUser.DoesNotExist:
            return Response(
                {"error": "User not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        if user.user_type == "driver":
            try:
                driver = user.driver
                serializer = DriverProfileSerializer(driver)
            except Driver.DoesNotExist:
                return Response(
                    {"error": "Driver profile not found"},
                    status=status.HTTP_404_NOT_FOUND
                )

        elif user.user_type == "rider":
            try:
                rider = user.rider
                serializer = RiderProfileSerializer(rider)
            except Rider.DoesNotExist:
                return Response(
                    {"error": "Rider profile not found"},
                    status=status.HTTP_404_NOT_FOUND
                )

        else:
            return Response(
                {"error": "Invalid user type"},
                status=status.HTTP_400_BAD_REQUEST
            )

        return Response(serializer.data, status=status.HTTP_200_OK)


class UpdateDriverProfile(APIView):

    def patch(self, request):
        user = request.user

        if user.user_type != "driver":
            return Response({"error": "Only drivers can update profile"}, status=status.HTTP_403_FORBIDDEN)

        try:
            driver = user.driver
        except Driver.DoesNotExist:
            return Response({"error": "Driver profile not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = DriverProfileUpdateSerializer(driver, data=request.data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UpdateRiderProfile(APIView):

    def patch(self, request):
        user = request.user

        if user.user_type != "rider":
            return Response({"error": "Only riders can update this profile."}, status=status.HTTP_403_FORBIDDEN)

        try:
            rider = Rider.objects.get(user=user)
        except Rider.DoesNotExist:
            return Response({"error": "Rider profile not found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = RiderProfileUpdateSerializer(rider, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



