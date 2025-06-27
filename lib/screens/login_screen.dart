import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_node_video_editor/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authenticationProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF377D9A),
      body: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "jua"),
            "Authentication",
          ),
          Center(
            child: InkWell(
              onTap: () async {
                await auth.signIn();
              },
              enableFeedback: true,
              child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset('lib/assets/images/google.png')),
            ),
          ),
        ],
      ),
    );
  }
}
