import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/app/home_page.dart';
import 'package:time_tracker_flutter_course/app/sign_in/sign_in_page.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  
  FirebaseUser _user;

  @override
  void initState() {
    checkCurrentUser();
    super.initState();
  }

  Future<void> checkCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    _updateUser(user);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return SignInPage(
        onSignIn: (user) => _updateUser(user),
        // onSignIn: _updateUser
      );
    }

    return HomePage(
      onSignOut: () => _updateUser(null),
    );
  }

  void _updateUser(FirebaseUser user) {
    setState(() {
      _user = user;
    });
  }
}
