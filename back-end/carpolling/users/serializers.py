from rest_framework import serializers

from django.conf import settings
from .models import MainUser, Driver, Rider, AppAdmin

class RegistrationSerializer(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True)
    class Meta:
        model = MainUser
        fields = ('name', 'email', 'password', "confirm_password", 'user_type')
        extra_kwargs = {'password': {'write_only': True}}
    def validate(self, attrs):
        name= attrs.get('name')
        user_type = attrs.get('user_type')
        email= attrs.get('email')
        password= attrs.get('password')
        confirm_password = attrs.get("confirm_password")
        if password != confirm_password:
            raise serializers.ValidationError({
                "confirm_password": "Passwords do not match."
            })
        if user_type == 'admin':
            if email != settings.ADMIN_EMAIL or password != settings.ADMIN_PASSWORD:
                raise serializers.ValidationError(
                    {"user_type": "An admin account is wrong."}
                )
        return attrs
    def create(self, validated_data):
        validated_data.pop("confirm_password")
        password = validated_data.pop('password', None)
        user = MainUser.objects.create_user(
            password=password,
            **validated_data
        )
        if user.user_type == 'driver':
            if not hasattr(user, 'driver'):
                Driver.objects.create(user=user)
        elif user.user_type == 'rider':
            if not hasattr(user, 'rider'):
                Rider.objects.create(user=user)
        elif user.user_type == 'admin':
            AppAdmin.objects.get_or_create(user=user)
        return user

class VerifyEmailSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)

class ResendVerificationSerializer(serializers.Serializer):
    email = serializers.EmailField()

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

class VerifyResetCodeSerializer(serializers.Serializer):
    reset_token = serializers.CharField()
    code = serializers.CharField(max_length=6)

class ResendResetCodeSerializer(serializers.Serializer):
    reset_token = serializers.CharField()

class ResetPasswordSerializer(serializers.Serializer):
    reset_token = serializers.CharField()
    new_password = serializers.CharField(write_only=True, min_length=8)
    confirm_password = serializers.CharField(write_only=True, min_length= 8)
    def validate(self, attrs):
        if attrs["new_password"] != attrs["confirm_password"]:
            raise serializers.ValidationError({
                "confirm_password": "Passwords do not match."
            })

        return attrs

class MainUserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = MainUser
        fields = ["name","created_at","phone", "profile_picture"]
        
class DriverProfileSerializer(serializers.ModelSerializer):
    user = MainUserProfileSerializer(read_only=True)

    class Meta:
        model = Driver
        fields = (
            "user",
            "car_model",
            "car_number",
            "car_color",
            "car_image"
        )

class RiderProfileSerializer(serializers.ModelSerializer):
    user = MainUserProfileSerializer(read_only=True)

    class Meta:
        model = Rider
        fields = (
            "user",
            "current_location"
        )


class DriverProfileUpdateSerializer(serializers.ModelSerializer):
    
    name = serializers.CharField(source="user.name", required=False)
    phone = serializers.CharField(source="user.phone", required=False)
    email = serializers.EmailField(source="user.email", required=False)
    profile_picture = serializers.ImageField(
        source="user.profile_picture", required=False
    )

    class Meta:
        model = Driver
        fields = [
            "name",
            "phone",
            "email",
            "profile_picture",
            "car_number",
            "car_color",
            "car_image"
        ]

    def update(self, instance, validated_data):
        
        user_data = validated_data.pop("user", {})
        for attr, value in user_data.items():
            setattr(instance.user, attr, value)
        instance.user.save()

        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        return instance



class RiderProfileUpdateSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source="user.name", required=False)
    phone = serializers.CharField(source="user.phone", required=False)
    email = serializers.EmailField(source="user.email", required=False)
    profile_picture = serializers.ImageField(
        source="user.profile_picture", required=False
    )

    class Meta:
        model = Rider
        fields = [
            "name",
            "phone",
            "email",
            "profile_picture",
            "current_location"
        ]

    def update(self, instance, validated_data):
     
        user_data = validated_data.pop("user", {})
        for attr, value in user_data.items():
            setattr(instance.user, attr, value)
        instance.user.save()

        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        return instance