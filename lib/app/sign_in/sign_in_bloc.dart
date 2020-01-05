import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:time_tracker_flutter_course/services/Auth.dart';

class SignInBloc {

  SignInBloc({@required this.auth});

  final AuthBase auth;
  final _isLoadingController = StreamController<bool>();

  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  void dispose() {
    _isLoadingController.close();
  }

  void _setIsLoading(bool isLoadingParam) => _isLoadingController.add(isLoadingParam);

  Future<User> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);

  Future<User> signInWithFacebook() async => await _signIn(auth.signInWithFacebook);

  Future<User> signInAnonymously() async => await _signIn(auth.signInAnonymously);

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      _setIsLoading(true);
      return await signInMethod();
    } catch(e) {
      _setIsLoading(false);
      rethrow;
    }
  }

}