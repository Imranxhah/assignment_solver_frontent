from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .serializers import (
    UserSerializer, RegisterSerializer, LoginSerializer,
    VerifyEmailSerializer, ForgotPasswordSerializer,
    ResetPasswordSerializer, ChangePasswordSerializer, UserProfileSerializer
)
from .models import User, VerificationCode, UserProfile
from django.core.mail import send_mail
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from django.views.decorators.csrf import csrf_exempt

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    email = request.data.get('email')
    if not email:
        return Response({'email': ['This field may not be blank.']}, status=status.HTTP_400_BAD_REQUEST)

    try:
        user = User.objects.get(email=email)
        if user.is_email_verified:
            return Response({'email': ['A user with that email already exists.']}, status=status.HTTP_400_BAD_REQUEST)
        else:
            # User exists but is not verified. Resend code and tell client to verify.
            send_verification_email(user)
            return Response({
                'email': email,
                'needsVerification': True,
                'message': 'This email is already registered but not verified. A new verification code has been sent.'
            }, status=status.HTTP_409_CONFLICT)
    except User.DoesNotExist:
        # New user, proceed with registration
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            send_verification_email(user)
            # On new registration, also tell client to verify
            return Response({
                'email': user.email,
                'needsVerification': True,
                'message': 'Registration successful! Please check your email to verify your account.'
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)

        if not user.check_password(password):
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)

        if not user.is_email_verified:
            send_verification_email(user)  # Resend email
            return Response({'error': 'Email not verified. A new code has been sent.'}, status=status.HTTP_401_UNAUTHORIZED)

        refresh = RefreshToken.for_user(user)
        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        })
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email(request):
    serializer = VerifyEmailSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        code = serializer.validated_data['code']
        try:
            user = User.objects.get(email=email)
            verification_code = VerificationCode.objects.get(user=user, code=code)
        except (User.DoesNotExist, VerificationCode.DoesNotExist):
            return Response({'error': 'Invalid code'}, status=status.HTTP_400_BAD_REQUEST)

        if not verification_code.is_valid():
            return Response({'error': 'Code expired'}, status=status.HTTP_400_BAD_REQUEST)

        user.is_email_verified = True
        user.save()
        verification_code.delete()
        return Response({'message': 'Email verified successfully'}, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

def send_verification_email(user):
    code = VerificationCode.generate_code()
    VerificationCode.objects.create(user=user, code=code)
    send_mail(
        'Verify your email',
        f'Your verification code is: {code}',
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=False,
    )

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def send_verification_email_view(request):
    email = request.data.get('email')
    if not email:
        return Response({'error': 'Email is required'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    
    send_verification_email(user)
    return Response({'message': 'Verification email sent'}, status=status.HTTP_200_OK)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    serializer = ForgotPasswordSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            # Do not reveal if user exists, but still return a success response
            return Response(status=status.HTTP_200_OK)

        if not user.is_email_verified:
            # User is not verified, treat it like a registration that needs verification
            send_verification_email(user)
            return Response({
                'email': email,
                'needsVerification': True,
                'message': 'This account is not verified. A new verification code has been sent to complete your registration.'
            }, status=status.HTTP_409_CONFLICT)
        else:
            # User is verified, proceed with password reset flow
            send_verification_email(user) # This sends a code for password reset
            return Response({'message': 'A password reset code has been sent to your email.'}, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password(request):
    serializer = ResetPasswordSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        code = serializer.validated_data['code']
        password = serializer.validated_data['password']
        try:
            user = User.objects.get(email=email)
            verification_code = VerificationCode.objects.get(user=user, code=code)
        except (User.DoesNotExist, VerificationCode.DoesNotExist):
            return Response({'error': 'Invalid code'}, status=status.HTTP_400_BAD_REQUEST)

        if not verification_code.is_valid():
            return Response({'error': 'Code expired'}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(password)
        user.save()
        verification_code.delete()
        return Response({'message': 'Password reset successfully'}, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST', 'PATCH'])
@permission_classes([IsAuthenticated])
def complete_profile(request):
    try:
        profile = request.user.profile
    except UserProfile.DoesNotExist:
        profile = None

    serializer = UserProfileSerializer(instance=profile, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save(user=request.user)
        request.user.profile_completed = True
        request.user.save()
        return Response(UserSerializer(request.user).data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_info(request):
    user = request.user
    serializer = UserSerializer(user)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    serializer = ChangePasswordSerializer(data=request.data)
    if serializer.is_valid():
        user = request.user
        old_password = serializer.validated_data['old_password']
        new_password = serializer.validated_data['new_password']

        if not user.check_password(old_password):
            return Response({'error': 'Invalid old password'}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save()
        return Response({'message': 'Password changed successfully'}, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)