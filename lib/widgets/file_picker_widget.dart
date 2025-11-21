import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';

class FilePickerWidget extends StatefulWidget {
  final Function(String?) onFilePicked;
  final List<String> allowedExtensions;

  const FilePickerWidget({
    super.key,
    required this.onFilePicked,
    this.allowedExtensions = const ['pdf', 'docx', 'pptx'],
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  String? _filePath;
  String? _fileName;
  String? _fileSize;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileSize = file.lengthSync();
        final fileSizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

        setState(() {
          _filePath = result.files.single.path;
          _fileName = result.files.single.name;
          _fileSize = '$fileSizeInMB MB';
        });

        widget.onFilePicked(_filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error picking file: $e')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _filePath = null;
      _fileName = null;
      _fileSize = null;
    });
    widget.onFilePicked(null);
  }

  IconData _getFileIcon() {
    if (_fileName == null) return Iconsax.document;

    final extension = _fileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Iconsax.document_text;
      case 'docx':
        return Iconsax.document_text_1;
      case 'pptx':
        return Iconsax.document_text;
      default:
        return Iconsax.document;
    }
  }

  Color _getFileColor() {
    if (_fileName == null) return Colors.blue;

    final extension = _fileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return const Color(0xFFE53935);
      case 'docx':
        return const Color(0xFF2196F3);
      case 'pptx':
        return const Color(0xFFFF6F00);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_filePath != null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickFile,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getFileColor(),
                          _getFileColor().withAlpha(204),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _getFileColor().withAlpha(77),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getFileIcon(),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _fileName ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getFileColor().withAlpha(26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _fileName!.split('.').last.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getFileColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.circle,
                              size: 4,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _fileSize ?? '',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.error.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Iconsax.trash,
                        color: colorScheme.error,
                        size: 20,
                      ),
                      onPressed: _removeFile,
                      tooltip: 'Remove file',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ✅ FIXED: Using LayoutBuilder to adapt to available space
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withAlpha(77),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(20),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            // ✅ Changed to SingleChildScrollView to handle overflow gracefully
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withAlpha(26),
                          colorScheme.primary.withAlpha(13),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.document_upload,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Upload Your Assignment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tap to browse files',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: widget.allowedExtensions.map((ext) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.primary.withAlpha(51),
                          ),
                        ),
                        child: Text(
                          ext.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
