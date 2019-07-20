import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/services/Auth.dart';

class HomePage extends StatelessWidget {
  HomePage({@required this.auth, @required this.onSignOut});

  final VoidCallback onSignOut;
  final AuthBase auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Logout",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            onPressed: _signOut,
          )
        ],
      ),
    );
  }

  /// Firebase anonymous auth
  Future<void> _signOut() async {
    try {
      await auth.signOut();
      onSignOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
