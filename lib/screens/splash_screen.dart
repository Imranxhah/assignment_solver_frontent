import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_version_model.dart';
import '../providers/auth_provider.dart';
import '../services/app_service.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // First, check for updates.
    final needsUpdate = await _checkVersion();

    // If a force update is required, the dialog will be shown and the code below will not run.
    if (needsUpdate) return;

    // If no forced update, proceed with normal initialization.
    _continueToApp();
  }

  Future<bool> _checkVersion() async {
    final result = await AppService.getAppVersion();
    if (result['success']) {
      final AppVersion serverVersion = result['version'];
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int currentBuildNumber = int.parse(packageInfo.buildNumber);

      if (serverVersion.forceUpdate && serverVersion.versionCode > currentBuildNumber) {
        _showForceUpdateDialog(serverVersion);
        return true; // Indicates an update is required
      }
    }
    // If check fails or no update is needed, continue.
    return false;
  }

  void _showForceUpdateDialog(AppVersion version) {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (context) => PopScope(
        canPop: false, // User cannot use back button
        child: AlertDialog(
          title: const Text('Update Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('A new version (${version.versionName}) is available. You must update to continue.'),
                const SizedBox(height: 16),
                const Text('Release Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(version.releaseNotes),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Update Now'),
              onPressed: () {
                // This URL should be your app's store URL
                _launchURL('https://play.google.com/store/apps/details?id=com.example.assignment_solver_app');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Could not launch URL
    }
  }

  Future<void> _continueToApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      if (!authProvider.isEmailVerified) {
        Navigator.pushReplacementNamed(context, '/email-verification');
      } else if (!authProvider.isProfileCompleted) {
        Navigator.pushReplacementNamed(context, '/profile-completion');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_rounded,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Solve it',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-Powered Solutions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 48),
            const SpinKitFadingCircle(
              color: Colors.white,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
