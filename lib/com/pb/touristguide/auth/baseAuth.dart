import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  String getCurrentUser();

  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String currentUserId;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    currentUserId = result.user.uid;
    return currentUserId;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user.uid;
  }

  String getCurrentUser() {
    return currentUserId;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
