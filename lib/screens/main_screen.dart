import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:govideoeditor/backend/dart/fetch_data.dart';
import 'package:govideoeditor/backend/dart/upload_video.dart';
import 'package:govideoeditor/models/height_width.dart';
import 'package:govideoeditor/providers/sha_provider.dart';
import 'package:govideoeditor/providers/video_file_provider.dart';
import 'package:govideoeditor/screens/functionalities.dart';
import 'package:govideoeditor/widgets/bar.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends ConsumerState<MainScreen> {
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
    // final sha = ref.read(shaProvider);
    final videoFile = ref.watch(videoProvider);
    final uploadstate = ref.watch(uploadProvider);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: <Color>[Colors.blue, Colors.pink])),
              child: const Bar(),
            )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Align(
              alignment: Alignment.center,
              child: uploadstate == UploadStatus.uploading
                  ? const CircularProgressIndicator()
                  : uploadstate == UploadStatus.success && videoFile != null
                      ? FutureBuilder(
                          future: fetchThumbnail("thumnail", ref),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SizedBox(
                                width: HeightWidth.width! * 0.7,
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
                              return const Center();
                            }
                            return const CircularProgressIndicator();
                          })
                      : uploadstate == UploadStatus.error
                          ? materialbanner(context, ref)
                          : DottedBorder(
                              borderType: BorderType.RRect,
                              color: Colors.purple,
                              radius: const Radius.circular(12),
                              child: SizedBox(
                                  width: HeightWidth.width! * 0.7,
                                  height: HeightWidth.height! * 0.25,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                            pickVideo(ref);
                                          },
                                          icon:
                                              const Icon(Icons.upload_rounded)),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text("Upload the video file"),
                                    ],
                                  )),
                            ),
            ),
            if (uploadstate == UploadStatus.success && videoFile != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: ElevatedButton(
                    onPressed: () {
                      ref.watch(videoProvider.notifier).clearvideo();
                    },
                    child: const Text("Cancel")),
              ),
            if (uploadstate == UploadStatus.success && videoFile != null) const Functionalities()
          ],
        ));
  }
}
