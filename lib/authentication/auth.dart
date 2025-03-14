import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get stateChange => _auth.authStateChanges();
  String? get uid => _auth.currentUser!.uid;
  Future<dynamic> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credentials = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      await _auth.signInWithCredential(credentials);
    } on Exception catch (e) {
      print("authentication failed$e");
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      // await GoogleSignIn().disconnect();
    } catch (e) {
      throw Exception("sorry dear something went wrong ${e.toString()}");
    } finally {}
  }
}
