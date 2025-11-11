import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';
import 'api_service.dart';

class DownloadService {
  static final Dio _dio = Dio();

  /// Download PDF file to device with authentication
  static Future<Map<String, dynamic>> downloadPDF({
    required String url,
    required String filename,
    Function(double)? onProgress,
  }) async {
    try {
      // Get JWT token
      var token = await StorageService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return {
          'success': false,
          'message': 'Storage permission denied',
        };
      }

      // Get download directory
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        return {
          'success': false,
          'message': 'Could not access download directory',
        };
      }

      // Create full path
      final filePath = '${directory.path}/$filename';

      // Try download with current token
      try {
        await _dio.download(
          url,
          filePath,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total != -1 && onProgress != null) {
              final progress = (received / total);
              onProgress(progress);
            }
          },
        );
      } on DioException catch (e) {
        // If 401, try refreshing token and retry
        if (e.response?.statusCode == 401) {
          final refreshed = await ApiService.refreshToken();
          if (refreshed) {
            token = await StorageService.getAccessToken();

            // Retry download with new token
            await _dio.download(
              url,
              filePath,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ),
              onReceiveProgress: (received, total) {
                if (total != -1 && onProgress != null) {
                  final progress = (received / total);
                  onProgress(progress);
                }
              },
            );
          } else {
            throw DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: DioExceptionType.badResponse,
              error: 'Session expired. Please login again.',
            );
          }
        } else {
          rethrow;
        }
      }

      return {
        'success': true,
        'message': 'Download completed',
        'path': filePath,
      };
    } on DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please login again.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'File not found or expired (20 min limit).';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet.';
      } else if (e.message != null) {
        errorMessage = 'Download failed: ${e.message}';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Download failed: ${e.toString()}',
      };
    }
  }

  /// Request storage permission
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need specific permissions
      if (Platform.version.contains('33') || Platform.version.contains('34')) {
        // Android 13+ doesn't need WRITE_EXTERNAL_STORAGE for Downloads folder
        return true;
      }

      // For Android 11-12 (API 30-32)
      if (await Permission.storage.isGranted) {
        return true;
      }

      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // For Android 11+ try manageExternalStorage
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
    return true;
  }

  /// Get public Downloads directory
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // For Android 10+ (API 29+), use public Downloads directory
        // Path: /storage/emulated/0/Download/
        final Directory downloadsDir =
            Directory('/storage/emulated/0/Download');

        // Check if directory exists and is accessible
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }

        // Try alternative path
        final Directory altDownloadsDir =
            Directory('/storage/emulated/0/Downloads');
        if (await altDownloadsDir.exists()) {
          return altDownloadsDir;
        }

        // Fallback: Create Downloads folder in external storage
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Try to access public Downloads via parent directories
          final List<String> paths = externalDir.path.split('/');
          if (paths.contains('Android')) {
            final publicPath =
                paths.sublist(0, paths.indexOf('Android')).join('/');
            final publicDownloads = Directory('$publicPath/Download');

            if (await publicDownloads.exists()) {
              return publicDownloads;
            }

            // Try Downloads with 's'
            final publicDownloadsAlt = Directory('$publicPath/Downloads');
            if (await publicDownloadsAlt.exists()) {
              return publicDownloadsAlt;
            }
          }

          // Last fallback: app-specific directory
          final downloadDir = Directory('${externalDir.path}/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir;
        }
      }

      // iOS or fallback
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      // If all else fails, use app documents
      return await getApplicationDocumentsDirectory();
    }
  }
}
