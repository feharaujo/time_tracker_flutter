import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class User {
  User({@required this.uid});
  final String uid;
}

abstract class AuthBase {
  Future<User> currentUser();
  Future<User> signInAnonymously();
  Future<void> signOut();
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
    FirebaseUser firebaseUser = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(firebaseUser);
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  User _userFromFirebase(FirebaseUser firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return User(uid: firebaseUser.uid);
  }
}
