import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoFileProvider extends StateNotifier<File?> {
  VideoFileProvider() : super(null);
  void setVideo(File video) {
    state = video;
  }

  void clearvideo() {
    state = null;
  }
}

final videoProvider = StateNotifierProvider<VideoFileProvider, File?>((ref) {
  return VideoFileProvider();
});
