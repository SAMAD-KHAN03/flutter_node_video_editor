import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_node_video_editor/providers/sha_provider.dart';

Future<String> fetchThumbnail(WidgetRef ref) async {
  // final userId = ref.read(authenticationProvider).uid;
  var storageFolder = "image";
  var videoId = ref.read(shaProvider);
  // print("the userId ${userId} and the videoid ${videoId}");
  final url = await FirebaseStorage.instance
      .ref("$storageFolder/$videoId-thumbnail.jpg")
      .getDownloadURL();
  print("this is the url$url");
  return url;
}
