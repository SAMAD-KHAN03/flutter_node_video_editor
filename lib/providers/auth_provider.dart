import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_node_video_editor/authentication/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authenticationProvider = ChangeNotifierProvider<Auth>((ref) => Auth());
final authstateProvider = StreamProvider<User?>(
    (ref) => ref.read(authenticationProvider).stateChange);
