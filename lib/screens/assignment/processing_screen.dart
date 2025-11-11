import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/assignment_provider.dart';
import '../../models/assignment_model.dart';
import '../../utils/app_theme.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isProcessing = true;
  late AnimationController _animationController;

  final List<ProcessingStep> _steps = [
    ProcessingStep(
      icon: Iconsax.document_upload,
      title: 'Uploading File',
      subtitle: 'Sending your assignment to server...',
      estimatedSeconds: 3,
    ),
    ProcessingStep(
      icon: Iconsax.document_text,
      title: 'Extracting Content',
      subtitle: 'Reading and analyzing assignment...',
      estimatedSeconds: 5,
    ),
    ProcessingStep(
      icon: Iconsax.cpu_charge,
      title: 'AI Solution Generation',
      subtitle: 'Creating comprehensive solution...',
      estimatedSeconds: 35,
    ),
    ProcessingStep(
      icon: Iconsax.document_download,
      title: 'Generating PDF',
      subtitle: 'Compiling final document...',
      estimatedSeconds: 12,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAssignment();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processAssignment() async {
    final submission =
        ModalRoute.of(context)!.settings.arguments as AssignmentSubmission;
    final assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);

    // Simulate step progression
    _updateStep(0); // Uploading
    await Future.delayed(const Duration(seconds: 2));

    _updateStep(1); // Extracting
    await Future.delayed(const Duration(seconds: 3));

    _updateStep(2); // AI Processing

    // Start actual API call
    final success = await assignmentProvider.submitAssignment(submission);

    if (!mounted) return;

    if (success) {
      _updateStep(3); // Generating PDF - wait until complete
      await Future.delayed(const Duration(seconds: 2));

      // Mark all as complete
      setState(() {
        _currentStep = _steps.length;
        _isProcessing = false;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacementNamed(context, '/download');
    } else {
      setState(() => _isProcessing = false);
      _showErrorDialog(
          assignmentProvider.errorMessage ?? 'Failed to process assignment');
    }
  }

  void _updateStep(int step) {
    if (!mounted) return;
    setState(() => _currentStep = step);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Processing Failed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: SingleChildScrollView(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = _steps.length;
    final progress = _isProcessing ? (_currentStep / totalSteps) : 1.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Processing Assignment',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we generate your solution...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

                // Overall Progress
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(_currentStep + 1).clamp(0, totalSteps)}/$totalSteps',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Steps List (all steps displayed in order)
                ...List.generate(
                  _steps.length,
                  (index) {
                    final step = _steps[index];
                    final isActive = index == _currentStep && _isProcessing;
                    final isDone = index < _currentStep;

                    return _StepItem(
                      step: step,
                      isActive: isActive,
                      isDone: isDone,
                      animationController: _animationController,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Estimated Time Card - with proper dark mode support
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryColor.withValues(alpha: 0.15)
                        : AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.primaryColor.withValues(alpha: 0.3)
                          : AppTheme.primaryColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Iconsax.timer_1,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Time',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '45-60 seconds',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProcessingStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final int estimatedSeconds;

  ProcessingStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.estimatedSeconds,
  });
}

class _StepItem extends StatelessWidget {
  final ProcessingStep step;
  final bool isActive;
  final bool isDone;
  final AnimationController animationController;

  const _StepItem({
    required this.step,
    required this.isActive,
    required this.isDone,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    late Color iconColor;
    late Color containerBgColor;
    late Color borderColor;
    late Widget iconWidget;

    if (isDone) {
      // Done step - green success color
      iconColor = AppTheme.successColor;
      containerBgColor = AppTheme.successColor.withValues(alpha: 0.15);
      borderColor = AppTheme.successColor;
      iconWidget = Icon(Iconsax.tick_circle, color: iconColor, size: 32);
    } else if (isActive) {
      // Active step - orange primary color
      iconColor = AppTheme.primaryColor;
      containerBgColor = AppTheme.primaryColor.withValues(alpha: 0.15);
      borderColor = AppTheme.primaryColor;
      iconWidget = RotationTransition(
        turns: animationController,
        child: Icon(step.icon, color: iconColor, size: 32),
      );
    } else {
      // Undone step - use theme-aware colors
      if (isDark) {
        iconColor = const Color(0xFF9E9E9E); // Grey 500 for dark
        containerBgColor = const Color(0xFF424242)
            .withValues(alpha: 0.7); // Grey 800 with alpha
        borderColor = const Color(0xFF616161); // Grey 700
      } else {
        iconColor = const Color(0xFFBDBDBD); // Grey 400 for light
        containerBgColor = const Color(0xFFF5F5F5); // Grey 100
        borderColor = const Color(0xFFE0E0E0); // Grey 300
      }
      iconWidget = Icon(step.icon, color: iconColor, size: 32);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: containerBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: (isDone || isActive)
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark
                                ? const Color(0xFFBDBDBD)
                                : const Color(0xFF9E9E9E)),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: (isDone || isActive)
                            ? (isDark ? Colors.grey : Colors.grey)
                            : (isDark ? Colors.grey : const Color(0xFFA1A1A1)),
                      ),
                ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '~${step.estimatedSeconds}s',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Status Indicator
          if (isActive)
            SpinKitThreeBounce(
              color: AppTheme.primaryColor,
              size: 20,
            ),
          if (isDone)
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 24,
            ),
        ],
      ),
    );
  }
}
