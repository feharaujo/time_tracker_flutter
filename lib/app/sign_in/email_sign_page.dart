import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sign_in_form.dart';

class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          child: Card(child: EmailSignInForm()),
          padding: EdgeInsets.all(16.0),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
