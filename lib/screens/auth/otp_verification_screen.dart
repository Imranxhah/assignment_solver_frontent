import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/error_handler.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({required this.email, super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  int _resendCountdown = 0;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    // Clear previous errors
    setState(() => _errorMessage = '');

    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter verification code');
      return;
    }

    if (_codeController.text.length != 6) {
      setState(() => _errorMessage = 'Code must be 6 digits');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.verifyCode(
        widget.email,
        _codeController.text,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ErrorHandler.showSuccessSnackBar(
          context,
          message: 'Email verified successfully!',
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        final errorMessage = ApiService.handleError(response);
        setState(() => _errorMessage = errorMessage);
        ErrorHandler.showErrorSnackBar(
          context,
          message: errorMessage,
          onRetry: _verifyCode,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = ErrorHandler.getErrorMessage(e);
      setState(() => _errorMessage = errorMessage);
      ErrorHandler.showErrorSnackBar(
        context,
        message: errorMessage,
        onRetry: _verifyCode,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.sendVerificationCode(widget.email);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ErrorHandler.showSuccessSnackBar(
          context,
          message: 'Code resent to ${widget.email}',
        );

        // Start countdown
        setState(() => _resendCountdown = 60);
        _startCountdown();
      } else {
        final errorMessage = ApiService.handleError(response);
        setState(() => _errorMessage = errorMessage);
        ErrorHandler.showErrorSnackBar(
          context,
          message: errorMessage,
          onRetry: _resendCode,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = ErrorHandler.getErrorMessage(e);
      setState(() => _errorMessage = errorMessage);
      ErrorHandler.showErrorSnackBar(
        context,
        message: errorMessage,
        onRetry: _resendCode,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startCountdown() async {
    for (int i = 60; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _resendCountdown = i - 1);
      } else {
        break;
      }
    }
  }

  void _handleVerifyPress() {
    if (!_isLoading) {
      _verifyCode();
    }
  }

  void _handleResendPress() {
    if (!(_isLoading || _resendCountdown > 0)) {
      _resendCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Verifying code...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Iconsax.verify,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify Your Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a code to:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _codeController,
                  label: 'Verification Code',
                  hint: 'Enter 6-digit code',
                  keyboardType: TextInputType.number,
                  prefixIcon: Iconsax.code,
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Verify Code',
                    onPressed: _handleVerifyPress,
                    icon: Iconsax.verify,
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _handleResendPress,
                  child: Text(
                    _resendCountdown > 0
                        ? 'Resend in ${_resendCountdown}s'
                        : 'Didn\'t receive code? Resend',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
