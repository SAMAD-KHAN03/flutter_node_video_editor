import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_node_video_editor/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_node_video_editor/providers/sha_provider.dart';

Future<String> fetchThumbnail(WidgetRef ref) async {
  final userId = ref.read(authenticationProvider).uid;
  var videoId = ref.read(shaProvider);
  print("user id ${userId} and the video id ${videoId}");
  final url = await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection(videoId!)
      .doc("thumbnail")
      .get();
  return url['thumbnail'];
}
