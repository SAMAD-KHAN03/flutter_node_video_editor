import 'dart:io';

class Video {
  File? video;
  List<String> resizes = [];
  List<String> conversion = [];
  bool audio = false;
  String? thumbnailPath;

  // Corrected constructor
  Video(this.video, this.resizes, this.conversion, this.audio,
      this.thumbnailPath);
}
