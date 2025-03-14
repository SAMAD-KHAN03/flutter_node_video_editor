import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Download {
  Future<void> download() async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child("videos/1740690543833_output.mp4");

    try {
      Directory tempDir = await getTemporaryDirectory();
      File localFile = File("${tempDir.path}/downloaded_video.mp4");
      await fileRef.writeToFile(localFile);
      await moveFileToDownloads();
      print("File downloaded to: ${localFile.path}");
    } on FirebaseException catch (e) {
      print("Download failed: ${e.message}");
    }
  }

  Future<void> moveFileToDownloads() async {
    File privateFile = File(
        "/data/user/0/com.example.govideoeditor/cache/downloaded_video.mp4");

    if (!privateFile.existsSync()) {
      print("Source file does not exist!");
      return;
    }

    Directory? downloadsDir =
        await getExternalStorageDirectory(); // Get base storage
    String downloadsPath = "${downloadsDir!.path}/Download";

    // Ensure the directory exists
    Directory(downloadsPath).createSync(recursive: true);

    // New file path
    String newPath = "$downloadsPath/downloaded_video.mp4";

    try {
      privateFile.copySync(newPath);
      print("File moved to: $newPath");
    } catch (e) {
      print("Failed to move file: $e");
    }
  }
}
