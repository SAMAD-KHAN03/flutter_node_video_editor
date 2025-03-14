import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:govideoeditor/providers/video_file_provider.dart';

final shaProvider = StateProvider<String?>((ref) => null);

// Function to generate SHA-256 hash
Future<String> generateSHA256(File file) async {
  final bytes = await file.readAsBytes();
  final hash = sha256.convert(bytes);
  // print("the hash of this vidoe is " + );
  return hash.toString();
}

// Function to set SHA in Provider
Future<void> setSHAHash(WidgetRef ref) async {
  final file = ref.read(videoProvider);
  if (file != null) {
    String hash = await generateSHA256(file);
    ref.read(shaProvider.notifier).state = hash;
    print("the hash is $hash");
  }
}
