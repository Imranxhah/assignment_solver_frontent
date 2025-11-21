import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/app_theme.dart';
import '../../utils/error_handler.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _universityController;
  late TextEditingController _registrationController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final profile = user?.profile;

    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _universityController =
        TextEditingController(text: profile?.universityName ?? '');
    _registrationController =
        TextEditingController(text: profile?.registrationNumber ?? '');
    _departmentController =
        TextEditingController(text: profile?.departmentName ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _registrationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Validate
    if (_fullNameController.text.isEmpty ||
        _universityController.text.isEmpty ||
        _registrationController.text.isEmpty ||
        _departmentController.text.isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        message: 'All fields are required',
      );
      return;
    }

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await profileProvider.updateProfile(
      fullName: _fullNameController.text,
      universityName: _universityController.text,
      registrationNumber: _registrationController.text,
      departmentName: _departmentController.text,
    );

    if (!mounted) return;

    if (success) {
      // ✅ REFRESH USER DATA FROM SERVER AND UPDATE LOCAL STORAGE
      await authProvider.refreshUser();

      if (!mounted) return;

      ErrorHandler.showSuccessSnackBar(
        context,
        message: 'Profile updated successfully',
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ErrorHandler.showErrorSnackBar(
        context,
        message: profileProvider.errorMessage ?? 'Failed to update profile',
        onRetry: _saveProfile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Iconsax.user,
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Full Name
            CustomTextField(
              label: 'Full Name',
              controller: _fullNameController,
              prefixIcon: Iconsax.user,
            ),

            const SizedBox(height: 16),

            // University
            CustomTextField(
              label: 'University',
              controller: _universityController,
              prefixIcon: Iconsax.building,
            ),

            const SizedBox(height: 16),

            // Registration Number
            CustomTextField(
              label: 'Registration Number',
              controller: _registrationController,
              prefixIcon: Iconsax.document_text,
            ),

            const SizedBox(height: 16),

            // Department
            CustomTextField(
              label: 'Department',
              controller: _departmentController,
              prefixIcon: Iconsax.briefcase,
            ),

            const SizedBox(height: 32),

            // Save Button
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: _saveProfile,
                    isLoading: profileProvider.isLoading,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Iconsax.lock_1),
                label: const Text('Change Password'),
                onPressed: () {
                  Navigator.pushNamed(context, '/change-password');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
