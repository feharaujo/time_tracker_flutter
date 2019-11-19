import 'dart:io';

import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/app/sign_in/validators.dart';
import 'package:time_tracker_flutter_course/app/strings.dart';
import 'package:time_tracker_flutter_course/common_widgets/form_submit_button.dart';
import 'package:time_tracker_flutter_course/common_widgets/platform_alert_dialog.dart';
import 'package:time_tracker_flutter_course/services/Auth.dart';

enum EmailSignInFormType { signIn, register }

class EmailSignInForm extends StatefulWidget with EmailAndPasswordValidators {
  final AuthBase auth;

  EmailSignInForm({@required this.auth});

  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;

  String get _password => _passwordController.text;
  var _formType = EmailSignInFormType.signIn;
  bool _submitted = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: Key("main"),
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final primaryText =
        _formType == EmailSignInFormType.signIn ? BTN_SIGN_IN : BTN_REGISTER;
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? BTN_SEC_REGISTER
        : BTN_SEC_SIGN_IN;

    bool submitButtonEnabled = widget.emailValidator.isValid(_email) &&
        widget.passwordValidator.isValid(_password) &&
        !_isLoading;

    return [
      _buildEmailTextField(),
      _buildPasswordTextField(),
      SizedBox(
        height: 16,
      ),
      FormSubmitButton(
        text: primaryText,
        onPressed: submitButtonEnabled ? _submitForm : null,
      ),
      FlatButton(
        child: Text(secondaryText),
        onPressed: !_isLoading ? _toggleFormType : null,
      )
    ];
  }

  Widget _buildEmailTextField() {
    bool showErrorText = _submitted && !widget.emailValidator.isValid(_email);

    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      onEditingComplete: _emailEditingComplete,
      autocorrect: false,
      onChanged: (email) => _updateState(),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          labelText: "Email",
          hintText: "test@test.com",
          enabled: _isLoading == false,
          errorText: showErrorText ? widget.invalidEmailErrorText : null),
    );
  }

  Widget _buildPasswordTextField() {
    bool showErrorText =
        _submitted && !widget.passwordValidator.isValid(_password);

    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
          labelText: "Password",
          enabled: _isLoading == false,
          errorText: showErrorText ? widget.invalidPasswordErrorText : null),
      textInputAction: TextInputAction.done,
      onChanged: (passwd) => _updateState(),
      obscureText: true,
    );
  }

  void _submitForm() async {
    print("submitted call");

    setState(() {
      _submitted = true;
      _isLoading = true;
    });

    try {
      // simulate slow network
      //await Future.delayed(Duration(seconds: 3));

      if (_formType == EmailSignInFormType.signIn) {
        await widget.auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await widget.auth.createUserWithEmailAndPassword(_email, _password);
      }

      Navigator.of(context).pop();
    } catch (ex) {
      print(ex.toString());

      PlatformAlertDialog(
        title: "Sign in failed",
        content: ex.toString(),
        defaultActionText: "OK",
      ).show(context);

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFormType() {
    setState(() {
      _submitted = false;
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
    });

    _emailController.clear();
    _passwordController.clear();
  }

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email)
        ? _passwordFocusNode
        : _emailFocusNode;

    FocusScope.of(context).requestFocus(newFocus);
  }

  void _updateState() {
    setState(() {
      // do nothing
    });
  }
}
