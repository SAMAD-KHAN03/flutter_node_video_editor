import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:flutter_node_video_editor/providers/auth_provider.dart';
import 'package:flutter_node_video_editor/providers/sha_provider.dart';
import 'package:flutter_node_video_editor/providers/video_file_provider.dart';
import 'package:http_parser/http_parser.dart';

const ip = "192.168.1.97";
const port = "3000";

enum UploadStatus { idle, uploading, success, error }

class UploadNotifier extends StateNotifier<UploadStatus> {
  UploadNotifier() : super(UploadStatus.idle);
  void makeStateIdle() {
    state = UploadStatus.idle;
  }

  Future<void> uploadVideo(WidgetRef ref) async {
    final videoFile = ref.read(videoProvider);
    if (videoFile == null) return;

    final sha = ref.watch(shaProvider);
    final uid = ref.watch(authenticationProvider).uid;
    // print("$sha and the uid $uid");
    if (sha == null || uid == null) {
      print("Error: SHA or UID is null");
      state = UploadStatus.error;
      return; //  Stop execution if values are missing
    }

    final videoInfo = await FlutterVideoInfo().getVideoInfo(videoFile.path);
    // Proceed with upload
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        videoFile.path,
        filename: videoFile.path.split('/').last,
        contentType: MediaType('video', videoInfo!.mimetype!.split('/')[1]),
      ),
      "videoId": sha,
      "mime": videoInfo.mimetype!.split('/')[1],
      "operation": "thumbnail",
      "userId": uid,
      "duration": videoInfo.duration
    });

    Dio dio = Dio();
    state = UploadStatus.uploading;

    try {
      Response response = await dio.post(
        onSendProgress: (int sent, int total) {
          print("Sent: $sent Total: $total");
        },
        "http://$ip:$port/upload",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 200) {
        state = UploadStatus.success;
      } else {
        state = UploadStatus.error;
      }
    } catch (e) {
      print("Upload failed: $e");
      state = UploadStatus.error;
    } finally {
      print("the current status of upload is ${state}");
    }
  }
}

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadStatus>(
    (ref) => UploadNotifier());
