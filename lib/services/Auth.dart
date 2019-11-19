import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
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

  Future<User> signInWithFacebook();

  Future<User> signInWithEmailAndPassword(String email, String password);

  Future<User> createUserWithEmailAndPassword(String email, String password);

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

  /// Sign in with Google
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

  Future<User> signInWithFacebook() async {
    final facebookLogin = FacebookLogin();
    FacebookLoginResult result =
        await facebookLogin.logIn(['public_profile', 'email']);
    if (result.accessToken != null) {
      var token = result.accessToken.token;
      AuthResult authResult = await _firebaseAuth.signInWithCredential(
          FacebookAuthProvider.getCredential(accessToken: token));
      FirebaseUser firebaseUser = authResult.user;
      return _userFromFirebase(firebaseUser);
    } else {
      throw StateError('Missing Facebook access Token');
    }
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    AuthResult authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();

    return await _firebaseAuth.signOut();
  }

  /// Transform a Firebase user in a app level User object
  User _userFromFirebase(FirebaseUser firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return User(uid: firebaseUser.uid);
  }
}
