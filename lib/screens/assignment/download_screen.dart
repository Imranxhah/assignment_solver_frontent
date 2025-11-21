import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import '../../providers/assignment_provider.dart';
import '../../services/download_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_theme.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _downloadFile(String downloadUrl, String filename) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final result = await DownloadService.downloadPDF(
      url: downloadUrl,
      filename: filename,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
      });
    }

    if (!mounted) return;

    if (result['success']) {
      if (!mounted) return;

      // Show success dialog with saved path
      _showDownloadSuccessDialog(result['path'] ?? '');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDownloadSuccessDialog(String filePath) {
    // Extract only filename from the full path
    final displayPath = filePath.contains('/')
        ? 'Downloads/${filePath.split('/').last}'
        : 'Downloads/$filePath';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 60,
          ),
          title: const Text('Download Complete!'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(
                  'File saved successfully',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.document_text,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayPath,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                OpenFile.open(filePath);
              },
              icon: const Icon(
                Iconsax.document_download,
                size: 18,
                color: Colors.white,
              ),
              label: const Text('Open'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ Helper method to navigate and clear
  void _navigateToHome() {
    if (_isDownloading) return;

    Navigator.pushReplacementNamed(context, '/home').then((_) {
      // Clear data AFTER navigation completes
      if (mounted) {
        final provider = Provider.of<AssignmentProvider>(
          context,
          listen: false,
        );
        provider.clearLastSubmission();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    final response = assignmentProvider.lastSubmission;

    if (response == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text('No assignment data found'),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Go Back',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
              ),
            ],
          ),
        ),
      );
    }

    final downloadUrl = assignmentProvider.getDownloadUrl(response.downloadUrl);

    return PopScope(
      canPop: !_isDownloading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        // This is fine - only clears AFTER pop completes
        assignmentProvider.clearLastSubmission();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assignment Ready'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isDownloading ? null : _navigateToHome, // ✅ FIXED
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Icon(
                Iconsax.document_download,
                size: 50,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Success!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Download your solved Assignment',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Simplified File Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.document_text,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filename',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              response.filename,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Download Progress - Smooth animation
              if (_isDownloading) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Downloading...',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _downloadProgress,
                            minHeight: 12,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Download Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isDownloading ? 'Downloading...' : 'Download PDF',
                  onPressed: () {
                    if (_isDownloading) return;
                    _downloadFile(downloadUrl, response.filename);
                  },
                  icon: Iconsax.document_download,
                  isLoading: _isDownloading,
                ),
              ),

              const SizedBox(height: 16),

              // ✅ FIXED: Back Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Back to Home',
                  onPressed: _navigateToHome, // ✅ FIXED - Use helper method
                  isOutlined: true,
                  icon: Iconsax.home,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
