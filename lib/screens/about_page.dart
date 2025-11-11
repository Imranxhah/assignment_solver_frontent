import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailUri = Uri.parse(
        'mailto:imran21532@abasyn.edu.pk?subject=Need help about your Solve it app');

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No email app found. Please install Gmail or another email app.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Solve it',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo/Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Iconsax.document_text,
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Name and Version
            Center(
              child: Column(
                children: [
                  Text(
                    'Solve it',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            _SectionTitle('About the App'),
            const SizedBox(height: 12),
            Text(
              'Solve it is an innovative educational application designed to help students generate comprehensive, well-structured solutions for their academic assignments.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    height: 1.6,
                  ),
            ),

            const SizedBox(height: 24),

            // Features Section
            _SectionTitle('Key Features'),
            const SizedBox(height: 12),
            _FeatureItem(
              icon: Iconsax.document_upload,
              title: 'Easy Upload',
              description:
                  'Upload your assignments in PDF, DOCX, or PPTX format',
              context: context,
            ),
            const SizedBox(height: 12),
            _FeatureItem(
              icon: Iconsax.cpu_charge,
              title: 'AI-Powered Generation',
              description:
                  'Get intelligent, comprehensive solutions for your assignments',
              context: context,
            ),
            const SizedBox(height: 12),
            _FeatureItem(
              icon: Iconsax.document_download,
              title: 'PDF Export',
              description:
                  'Download your solutions as professionally formatted PDFs',
              context: context,
            ),
            const SizedBox(height: 12),
            _FeatureItem(
              icon: Iconsax.lock,
              title: 'Secure & Private',
              description:
                  'Your data is encrypted and kept secure on our servers',
              context: context,
            ),

            const SizedBox(height: 24),

            // How It Works
            _SectionTitle('How It Works'),
            const SizedBox(height: 12),
            _StepItem(
              step: 1,
              title: 'Upload Assignment',
              description:
                  'Submit your assignment file along with subject details',
              context: context,
            ),
            const SizedBox(height: 12),
            _StepItem(
              step: 2,
              title: 'Processing',
              description:
                  'Our system analyzes and generates a comprehensive solution',
              context: context,
            ),
            const SizedBox(height: 12),
            _StepItem(
              step: 3,
              title: 'Download',
              description:
                  'Get your solution as a professionally formatted PDF',
              context: context,
            ),

            const SizedBox(height: 32),

            // Developer Section - Improved
            Center(
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Developed by ',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: 'Imran Shah',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppTheme.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextSpan(
                          text: ' with ❤️',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Section
            _SectionTitle('Need Help?'),
            const SizedBox(height: 12),
            Text(
              'Have questions or need assistance? Send us an email and we\'ll get back to you as soon as possible.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendEmail(context),
                icon: const Icon(
                  Iconsax.sms,
                  color: Colors.white,
                ),
                label: const Text('Send Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Disclaimer - Using AppTheme colors
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Disclaimer: This app is designed to assist learning. Always verify solutions and complete assignments with your own understanding.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.warningColor,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final BuildContext context;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String title;
  final String description;
  final BuildContext context;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
