import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_node_video_editor/backend/dart/fetch_data.dart';
import 'package:flutter_node_video_editor/backend/dart/upload_video.dart';
import 'package:flutter_node_video_editor/models/height_width.dart';
import 'package:flutter_node_video_editor/providers/sha_provider.dart';
import 'package:flutter_node_video_editor/providers/video_file_provider.dart';
import 'package:flutter_node_video_editor/screens/functionalities.dart';
import 'package:flutter_node_video_editor/widgets/bar.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
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

outlinedButton(Iconify icon, double containerSize, double padding) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8)),
      child: icon,
    ),
  );
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF377D9A),
          actions: [
            outlinedButton(Iconify(Ic.arrow_back), 28, 16),
            Spacer(),
            Text("DashBoard"),
            Spacer(),
            outlinedButton(Iconify(Ic.outline_person), 28, 16)
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
            Positioned(
              top: HeightWidth.height! * 0.05,
              left: HeightWidth.width! * 0.1,
              right: HeightWidth.width! * 0.1,
              child: uploadstate == UploadStatus.uploading
                  ? const CircularProgressIndicator()
                  : uploadstate == UploadStatus.success && videoFile != null
                      ? FutureBuilder(
                          future: fetchThumbnail("thumnail", ref),
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
                              return const Center(
                                child: Text("some "),
                              );
                            }
                            return const CircularProgressIndicator();
                          })
                      : uploadstate == UploadStatus.error
                          ? materialbanner(context, ref)
                          : Container(
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
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: GestureDetector(
                                        onTap: () => pickVideo(ref),
                                        child: Iconify(
                                          Ep.upload,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    Text("Upload Video")
                                  ],
                                ),
                              ),
                              width: HeightWidth.width! * 0.8,
                              height: HeightWidth.height! * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                            ),
            ),
            if (uploadstate == UploadStatus.success && videoFile != null)
              Positioned(
                top: HeightWidth.height! * 0.3 + HeightWidth.height! * 0.02,
                left: HeightWidth.width! * 0.35,
                right: HeightWidth.width! * 0.35,
                child: Container(
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                ),
              ),
            // if (uploadstate == UploadStatus.success && videoFile != null)
            Functionalities()
          ],
        ));
  }
}
/**FutureBuilder(
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
                              )
                              
                               onPressed: () {
                        ref.watch(videoProvider.notifier).clearvideo();
                      }, */
