import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sign_in_form.dart';
import 'package:time_tracker_flutter_course/services/Auth.dart';

class EmailSignInPage extends StatelessWidget {

  final AuthBase auth;

  EmailSignInPage({@required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          child: Card(child: EmailSignInForm(auth: auth,)),
          padding: EdgeInsets.all(16.0),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

}
