import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  User({@required this.uid});
  final String uid;
}

abstract class AuthBase {
  Future<User> currentUser();
  Future<User> signInAnonymously();
  Future<void> signOut();
  Future<User> signInWithGoogle();
  Stream<User> get onAuthStateChanged;
}

class Auth implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<User> currentUser() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    return _userFromFirebase(firebaseUser);
  }

  Future<User> signInAnonymously() async {
    AuthResult authResult = await _firebaseAuth.signInAnonymously();
    FirebaseUser firebaseUser = authResult.user;
    return _userFromFirebase(firebaseUser);
  }

  /**
   * Sign in with Google
   */
  Future<User> signInWithGoogle() async {
    var googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        AuthResult authResult = await _firebaseAuth.signInWithCredential(
            GoogleAuthProvider.getCredential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken));
        FirebaseUser firebaseUser = authResult.user;
        return _userFromFirebase(firebaseUser);
      } else {
        throw StateError('Missing Google Auth Token');
      }
    } else {
      throw StateError('Google sign in aborted');
    }
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  /**
   * Transform a Firebase user in a app level User object
   */
  User _userFromFirebase(FirebaseUser firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return User(uid: firebaseUser.uid);
  }
}
