import 'package:assignment_solver_app/screens/profile/change_password_screen.dart';
import 'package:assignment_solver_app/screens/auth/forgot_password_screen.dart';
import 'package:assignment_solver_app/screens/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/assignment_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/profile/profile_completion_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/assignment/assignment_submission_screen.dart';
import 'screens/assignment/processing_screen.dart';
import 'screens/assignment/download_screen.dart';
import 'screens/about_page.dart';
import 'screens/profile/profile_edit_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Solve it',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              if (settings.name != null &&
                  settings.name!.startsWith(ResetPasswordScreen.routeName)) {
                final uri = Uri.parse(settings.name!);
                final email = uri.queryParameters['email'];
                final code = uri.queryParameters['code'];

                if (email != null && code != null) {
                  return MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(email: email, code: code),
                  );
                }
              }
              return null;
            },
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/email-verification': (context) =>
                  const EmailVerificationScreen(),
              '/otp-verification': (context) {
                final email =
                    ModalRoute.of(context)?.settings.arguments as String? ?? '';
                return OTPVerificationScreen(email: email);
              },
              '/profile-completion': (context) =>
                  const ProfileCompletionScreen(),
              '/home': (context) => const HomeScreen(),
              '/profile-edit': (context) => const ProfileEditScreen(),
              '/assignment-submission': (context) =>
                  const AssignmentSubmissionScreen(),
              '/processing': (context) => const ProcessingScreen(),
              '/download': (context) => const DownloadScreen(),
              '/about': (context) => const AboutPage(),
              ForgotPasswordScreen.routeName: (context) =>
                  const ForgotPasswordScreen(),
              ChangePasswordScreen.routeName: (context) =>
                  const ChangePasswordScreen(),
            },
          );
        },
      ),
    );
  }
}
