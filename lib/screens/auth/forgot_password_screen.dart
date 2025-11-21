
import 'package:assignment_solver_app/screens/auth/password_reset_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/error_handler.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text;
      final result = await authProvider.forgotPassword(email);

      if (!mounted) return;

      if (result['success']) {
        final message = result['message'] as String?;
        if (result['needsVerification'] == true) {
          // Unverified user, redirect to OTP screen
          if (message != null) {
            ErrorHandler.showInfoSnackBar(context, message: message);
          }
          Navigator.pushReplacementNamed(context, '/otp-verification', arguments: email);
        } else {
          // Verified user, proceed to password reset verification
          if (message != null) {
            ErrorHandler.showSuccessSnackBar(context, message: message);
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  PasswordResetVerificationScreen(email: email),
            ),
          );
        }
      } else {
        final errorMessage = authProvider.errorMessage ?? 'An error occurred.';
        ErrorHandler.showErrorSnackBar(context, message: errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: LoadingOverlay(
        isLoading: authProvider.isLoading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SvgPicture.asset(
                //   'assets/icon/forgot_password.svg', // Replace with your asset
                //   height: 150,
                // ),
                const SizedBox(height: 32),
                const Text(
                  'Enter your email address to receive a password reset code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Send Reset Code',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
