import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:govideoeditor/providers/auth_provider.dart';
import 'package:govideoeditor/providers/sha_provider.dart';
import 'package:govideoeditor/providers/video_file_provider.dart';
import 'package:http_parser/http_parser.dart';

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
      // print("Error: SHA or UID is null");
      state = UploadStatus.error;
      return; //  Stop execution if values are missing
    }

    final videoInfo = await FlutterVideoInfo().getVideoInfo(videoFile.path);
    final exists = await alreadyExists(sha, uid);
    if (exists) {
      state = UploadStatus.success;
      return;
    }

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
        "http://10.0.2.2:3000/upload",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 200) {
        state = UploadStatus.success;
      } else {
        state = UploadStatus.error;
      }
    } catch (e) {
      // print("Upload failed: $e");
      state = UploadStatus.error;
    } finally {
      // print("the current status of upload is ${state}");
    }
  }

  Future<void> resizeVideo(String? height, String? width, WidgetRef ref) async {
    if (height == null || width == null) return;
    final videoId = ref.read(videoProvider);
    final userId = ref.read(authenticationProvider).uid;
    FormData formdata = FormData.fromMap({
      "userId": userId,
      "videoId": videoId,
      "width": width,
      "height": height,
    });
    Dio dio = Dio();
    try {
      Response response = await dio.post("http://10.0.2.2:3000/resize");
      if (response.statusCode == 200) {
        state = UploadStatus.success;
      } else {
        state = UploadStatus.error;
      }
    } catch (e) {
      print("error in resize function${e.toString()}");
    }
  }
}

Future<bool> alreadyExists(String videoId, String uid) async {
  QuerySnapshot collection = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection(videoId)
      .limit(1)
      .get();
  return collection.docs.isNotEmpty;
}

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadStatus>(
    (ref) => UploadNotifier());
