import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum DownlaodStatus { Downloading, Error, Downlaoded, idle }

class Download extends StateNotifier<DownlaodStatus> {
  Download() : super(DownlaodStatus.idle);

  static const platform = MethodChannel('com.example.govideoeditor/download');

  Future<void> download(String downloadUrl, String fileNameWithoutExt) async {
    try {
      state = DownlaodStatus.Downloading;

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          state = DownlaodStatus.Error;
          print("Storage permission denied");
          return;
        }
      }

      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) {
        state = DownlaodStatus.Error;
        throw Exception("Failed to download file: ${response.statusCode}");
      }

      // 🔍 Extract extension from URL and construct full file name
      final extension = _getFileExtensionFromUrl(downloadUrl);
      print("the extension found is ${extension}");
      final fileName = "$fileNameWithoutExt.$extension";

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempPath = "${tempDir.path}/$fileName";
      final file = File(tempPath);
      await file.writeAsBytes(response.bodyBytes);

      // Save to Downloads using platform channel
      await saveToDownloads(tempPath, fileName);

      print("Download completed and moved to Downloads");
      state = DownlaodStatus.Downlaoded;
    } catch (e) {
      state = DownlaodStatus.Error;
      print("Download failed: $e");
    }
  }

  Future<void> saveToDownloads(String filePath, String fileName) async {
    try {
      await platform.invokeMethod('saveToDownloads', {
        'filePath': filePath,
        'fileName': fileName,
      });
    } on PlatformException catch (e) {
      throw Exception("Failed to save to Downloads: ${e.message}");
    }
  }

  /// Extract file extension from the Firebase Storage URL
  String _getFileExtensionFromUrl(String url) {
    final decodedUrl = Uri.decodeFull(url);
    final match = RegExp(r'\.([a-zA-Z0-9]+)\?alt=media').firstMatch(decodedUrl);
    // print("the extension found is $match")
    return match != null ? match.group(1)! : 'bin'; // Fallback if not found
  }
}

final downlaodStateProvider =
    StateNotifierProvider<Download, DownlaodStatus>((ref) => Download());
