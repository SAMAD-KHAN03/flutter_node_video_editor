// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_node_video_editor/backend/dart/videos.dart';
import 'package:flutter_node_video_editor/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_node_video_editor/backend/dart/fetch_data.dart';
import 'package:flutter_node_video_editor/backend/dart/upload_video.dart';
import 'package:flutter_node_video_editor/models/height_width.dart';
import 'package:flutter_node_video_editor/providers/sha_provider.dart';
import 'package:flutter_node_video_editor/providers/video_file_provider.dart';
import 'package:flutter_node_video_editor/screens/functionalities.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/heroicons.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends ConsumerState<MainScreen> {
  outlinedButton(Iconify icon, double containerSize, double padding,
      BuildContext context, bool isLogin) {
    return InkWell(
      onTap: () async {
        isLogin
            ? await ref.watch(authenticationProvider).signOut()
            : Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Videos(),
              ));
      },
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8)),
          child: icon,
        ),
      ),
    );
  }

  Future<void> pickVideo(WidgetRef ref) async {
    final uploadstatNotifier = ref.read(uploadProvider.notifier);
    final XFile? selectedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (selectedVideo != null) {
      ref.watch(videoProvider.notifier).setVideo(File(selectedVideo.path));
      await setSHAHash(ref);
      await uploadstatNotifier.uploadVideo(ref);
    }
  }

  materialbanner(BuildContext context, WidgetRef ref) {
    final uploadstatNotifier = ref.read(uploadProvider.notifier);
    return WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: const Text("Something went wrong. Retry...."),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                uploadstatNotifier.makeStateIdle();
              },
              child: const Text("Dismiss"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sha = ref.read(shaProvider);

    final videoFile = ref.watch(videoProvider);
    final uploadstate = ref.watch(uploadProvider);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF377D9A),
          actions: [
            outlinedButton(Iconify(Ic.arrow_back), 28, 16, context, true),
            Spacer(),
            Text("DashBoard"),
            Spacer(),
            outlinedButton(Iconify(Ic.outline_person), 28, 16, context, false)
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    const Color(0xFF397E9B),
                    const Color(0xFF1F6381).withValues(alpha: .8),
                    const Color(0xFF142B35),
                  ])),
            ),
            uploadstate == UploadStatus.uploading
                ? Positioned(
                    top: HeightWidth.height! * 0.1,
                    left: (HeightWidth.width! / 2) - 25,
                    right: (HeightWidth.width! / 2) - 25,
                    child: const CircularProgressIndicator(),
                  )
                : Positioned(
                    top: HeightWidth.height! * 0.05,
                    left: HeightWidth.width! * 0.1,
                    right: HeightWidth.width! * 0.1,
                    child: uploadstate == UploadStatus.success &&
                            videoFile != null
                        ? FutureBuilder(
                            future: fetchThumbnail(ref),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return SizedBox(
                                  width: HeightWidth.width! * 0.8,
                                  height: HeightWidth.height! * 0.25,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        20), // Apply rounded edges
                                    child: Image.network(
                                      snapshot.data!,
                                      fit: BoxFit
                                          .fill, // Ensures the image fills the square properly
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text("${snapshot.error.toString()} "),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator(
                                      constraints: BoxConstraints(
                                          maxHeight: 25, maxWidth: 25)));
                            })
                        : Container(
                            width: HeightWidth.width! * 0.8,
                            height: HeightWidth.height! * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: GestureDetector(
                                      onTap: () => pickVideo(ref),
                                      child: const Iconify(
                                        Ep.upload,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const Text("Upload Video")
                                ],
                              ),
                            )),
                  ),
            if (uploadstate == UploadStatus.success && videoFile != null)
              Positioned(
                top: HeightWidth.height! * 0.3 + HeightWidth.height! * 0.02,
                left: HeightWidth.width! * 0.35,
                right: HeightWidth.width! * 0.35,
                child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 12,
                            color: Color.fromARGB(112, 0, 0, 0),
                            blurStyle: BlurStyle.outer),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final videoInfo = await FlutterVideoInfo()
                              .getVideoInfo(videoFile.path);

                          await http.delete(
                            Uri.parse("http://192.168.1.101:3000/delete"),
                            body: jsonEncode({
                              "videoId": sha,
                              "mime": videoInfo!.mimetype,
                            }),
                            headers: {"Content-Type": "application/json"},
                          );
                        } catch (e) {
                          // print("Error while deleting: $e");
                        } finally {
                          // print("inside finally");
                          ref.watch(videoProvider.notifier).clearvideo();
                          // print(videoProvider.notifier);
                          setState(() {});
                        }
                      },
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
              ),
            if (uploadstate == UploadStatus.success && videoFile != null)
              const Functionalities()
          ],
        ));
  }
}
