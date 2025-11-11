import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/assignment_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/file_picker_widget.dart';
import '../../utils/app_theme.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  const AssignmentSubmissionScreen({super.key});

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _assignmentNumberController = TextEditingController();
  final _tutorController = TextEditingController();
  String? _filePath;

  @override
  void dispose() {
    _subjectController.dispose();
    _assignmentNumberController.dispose();
    _tutorController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() && _filePath != null) {
      final submission = AssignmentSubmission(
        subjectName: _subjectController.text.trim(),
        assignmentNumber: _assignmentNumberController.text.trim(),
        tutorName: _tutorController.text.trim(),
        filePath: _filePath!,
      );

      Navigator.pushNamed(
        context,
        '/processing',
        arguments: submission,
      );
    } else if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Please select a file to upload'),
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Submit Assignment',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File Upload Section
              FilePickerWidget(
                onFilePicked: (path) {
                  setState(() {
                    _filePath = path;
                  });
                },
              ),

              const SizedBox(height: 28),

              // Form Fields Section
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.note_text,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Assignment Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please fill in all required information',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Subject Name',
                      hint: 'e.g., Computer Networks',
                      controller: _subjectController,
                      prefixIcon: Iconsax.book,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter subject name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Assignment Number',
                      hint: 'e.g., 1',
                      controller: _assignmentNumberController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Iconsax.hashtag,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter assignment number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Tutor Name',
                      hint: 'e.g., Dr. Ahmad',
                      controller: _tutorController,
                      prefixIcon: Iconsax.teacher,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter tutor name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info Tip with Icon
              Row(
                children: [
                  Icon(
                    Iconsax.clock,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Processing typically takes 30-60 seconds',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                height: 56,
                child: CustomButton(
                  text: 'Process Assignment',
                  onPressed: _handleSubmit,
                  icon: Iconsax.cpu,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
