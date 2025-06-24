import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_node_video_editor/backend/dart/videos.dart';
import 'package:flutter_node_video_editor/models/video.dart';
import 'package:flutter_node_video_editor/screens/functionalities.dart';
import 'package:flutter_node_video_editor/screens/main_clone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_node_video_editor/firebase_options.dart';
import 'package:flutter_node_video_editor/models/height_width.dart';
import 'package:flutter_node_video_editor/providers/auth_provider.dart';
import 'package:flutter_node_video_editor/screens/login_screen.dart';
import 'package:flutter_node_video_editor/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authstateProvider);
    return Builder(builder: (context) {
      HeightWidth.init(context);
      return MaterialApp(
        home: user.when(
          data: (data) {
            if (data != null) {
              print("data is not null");
              return const MainScreen();
            } else {
              print("data is  null");
              return const LoginScreen();
            }
          },
          error: (error, stackTrace) {
            print("the error is $error");
            return null;
          },
          loading: () => null,
        ),
      );
    });
  }
}
//inside the androind folder run ./gradlew signingReport to get sha1 key for firebase authentication
