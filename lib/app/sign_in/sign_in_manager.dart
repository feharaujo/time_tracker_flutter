import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:time_tracker_flutter_course/services/Auth.dart';

class SignInManager {

  SignInManager({@required this.auth, @required this.isLoading});

  final AuthBase auth;
  final ValueNotifier isLoading;

  Future<User> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);

  Future<User> signInWithFacebook() async => await _signIn(auth.signInWithFacebook);

  Future<User> signInAnonymously() async => await _signIn(auth.signInAnonymously);

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch(e) {
      isLoading.value = false;
      rethrow;
    }
  }

}