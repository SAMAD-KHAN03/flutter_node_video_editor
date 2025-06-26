import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_node_video_editor/providers/auth_provider.dart';
import 'package:flutter_node_video_editor/providers/sha_provider.dart';
import 'package:flutter_node_video_editor/providers/video_file_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_video_info/flutter_video_info.dart';

const ip = "192.168.1.97";
const port = "3000";

enum OperationStatus { completed, inprogress, error, idle }

class Operations extends StateNotifier<OperationStatus> {
  Operations() : super(OperationStatus.idle);
  Future<void> resizeVideo(String? height, String? width, WidgetRef ref) async {
    if (height == null || width == null) return;

    final videoFile = ref.read(videoProvider);
    final videoId = ref.read(shaProvider);
    final videoInfo = await FlutterVideoInfo().getVideoInfo(videoFile!.path);
    final userId = ref.read(authenticationProvider).uid;

    final data = {
      "userId": userId,
      "videoId": videoId,
      "width": width,
      "height": height,
      "mime": videoInfo!.mimetype,
    };

    try {
      state = OperationStatus.inprogress;
      final response = await http.post(
        Uri.parse("http://$ip:$port/resize"),
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        state = OperationStatus.completed;
        print("Resize operation done");
      }
    } catch (e) {
      state = OperationStatus.error;
      print("Error in resize function: ${e.toString()}");
    }
  }

  Future<void> audio(String encoding, WidgetRef ref) async {
    final videoId = ref.read(shaProvider);
    print("The videoId here in flutter is $videoId");
    final userId = ref.read(authenticationProvider).uid;
    final videoFile = ref.read(videoProvider);
    final videoInfo = await FlutterVideoInfo().getVideoInfo(videoFile!.path);

    final data = {
      "videoId": videoId,
      "userId": userId,
      "encoding": encoding,
      "mime": videoInfo!.mimetype
    };

    try {
      state = OperationStatus.inprogress;

      final response = await http.post(
        Uri.parse("http://$ip:$port/audio"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data), // 🔥 Must encode to JSON
      );

      if (response.statusCode == 200) {
        state = OperationStatus.completed;
        print("Audio extraction done");
      } else {
        state = OperationStatus.error;
        print(
            "Audio function failed with status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      state = OperationStatus.error;
      print("Error in audio function: ${e.toString()}");
    }
  }
}

final operationProvider =
    StateNotifierProvider<Operations, OperationStatus>((ref) => Operations());
