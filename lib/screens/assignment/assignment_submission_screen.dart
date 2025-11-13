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

class _AssignmentSubmissionScreenState extends State<AssignmentSubmissionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _assignmentNumberController = TextEditingController();
  final _tutorController = TextEditingController();
  final _textController = TextEditingController();
  String? _filePath;
  int _wordCount = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _textController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _subjectController.dispose();
    _assignmentNumberController.dispose();
    _tutorController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      if (_tabController.index == 1) {
        // Switched to Text tab - clear file
        _filePath = null;
      } else {
        // Switched to File tab - clear text
        _textController.clear();
        _wordCount = 0;
      }
    });
  }

  void _updateWordCount() {
    final text = _textController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() {
      _wordCount = words;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate based on active tab
    if (_tabController.index == 0) {
      // File Upload tab
      if (_filePath == null) {
        _showError('Please select a file to upload');
        return;
      }
    } else {
      // Text Input tab
      if (_textController.text.trim().isEmpty) {
        _showError('Please enter assignment text');
        return;
      }
      if (_wordCount > 2000) {
        _showError('Text exceeds maximum limit of 2000 words');
        return;
      }
      if (_wordCount < 10) {
        _showError('Please enter at least 10 words');
        return;
      }
    }

    final submission = AssignmentSubmission(
      subjectName: _subjectController.text.trim(),
      assignmentNumber: _assignmentNumberController.text.trim(),
      tutorName: _tutorController.text.trim(),
      filePath: _tabController.index == 0 ? _filePath : null,
      assignmentText:
          _tabController.index == 1 ? _textController.text.trim() : null,
    );

    Navigator.pushNamed(
      context,
      '/processing',
      arguments: submission,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
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
              // Tab Bar
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(5),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      height: 36,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.document_upload, size: 17),
                          SizedBox(width: 7),
                          Text('Upload File'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 36,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.edit_2, size: 17),
                          SizedBox(width: 7),
                          Text('Paste Text'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ FIXED: Smooth height animation without overflow
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _tabController.index == 0
                    ? (_filePath == null ? 220 : 110)
                    : 240,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // File Upload Tab
                    FilePickerWidget(
                      onFilePicked: (path) {
                        setState(() {
                          _filePath = path;
                        });
                      },
                    ),

                    // Text Input Tab
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Assignment Text',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: (_wordCount > 2000
                                          ? AppTheme.errorColor
                                          : colorScheme.primary)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (_wordCount > 2000
                                            ? AppTheme.errorColor
                                            : colorScheme.primary)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$_wordCount/2000',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _wordCount > 2000
                                        ? AppTheme.errorColor
                                        : colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText:
                                    'Paste your assignment questions here...',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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

              // Info Tip
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
