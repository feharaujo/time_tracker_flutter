import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sigin_in_bloc.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker_flutter_course/app/sign_in/validators.dart';
import 'package:time_tracker_flutter_course/app/strings.dart';
import 'package:time_tracker_flutter_course/common_widgets/form_submit_button.dart';
import 'package:time_tracker_flutter_course/common_widgets/platform_exception_alert_dialog.dart';
import 'package:time_tracker_flutter_course/services/Auth.dart';

class EmailSignInFormBlocBased extends StatefulWidget
    with EmailAndPasswordValidators {
  EmailSignInFormBlocBased({@required this.bloc});

  final EmailSignInBloc bloc;

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);

    return Provider<EmailSignInBloc>(
      create: (context) => EmailSignInBloc(auth: auth),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<EmailSignInBloc>(
        builder: (context, bloc, _) => EmailSignInFormBlocBased(
          bloc: bloc,
        ),
      ),
    );
  }

  @override
  _EmailSignInFormBlocBasedState createState() =>
      _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmailSignInModel>(
        stream: widget.bloc.modelStream,
        initialData: EmailSignInModel(),
        builder: (context, snapshot) {
          final emailSignInModel = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              key: Key("main"),
              mainAxisSize: MainAxisSize.min,
              children: _buildChildren(emailSignInModel),
            ),
          );
        });
  }

  List<Widget> _buildChildren(EmailSignInModel model) {
    final primaryText = model.formType == EmailSignInFormType.signIn
        ? BTN_SIGN_IN
        : BTN_REGISTER;
    final secondaryText = model.formType == EmailSignInFormType.signIn
        ? BTN_SEC_REGISTER
        : BTN_SEC_SIGN_IN;

    bool submitButtonEnabled = widget.emailValidator.isValid(model.email) &&
        widget.passwordValidator.isValid(model.password) &&
        !model.isLoading;

    return [
      _buildEmailTextField(model),
      _buildPasswordTextField(model),
      SizedBox(
        height: 16,
      ),
      FormSubmitButton(
        text: primaryText,
        onPressed: submitButtonEnabled ? _submitForm : null,
      ),
      FlatButton(
        child: Text(secondaryText),
        onPressed: !model.isLoading ? () => _toggleFormType(model) : null,
      )
    ];
  }

  Widget _buildEmailTextField(EmailSignInModel model) {
    bool showErrorText =
        model.isSubmitted && !widget.emailValidator.isValid(model.email);

    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      onEditingComplete: () => _emailEditingComplete(model),
      autocorrect: false,
      onChanged: (email) => widget.bloc.updateWith(email: email),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          labelText: "Email",
          hintText: "test@test.com",
          enabled: model.isLoading == false,
          errorText: showErrorText ? widget.invalidEmailErrorText : null),
    );
  }

  Widget _buildPasswordTextField(EmailSignInModel model) {
    bool showErrorText =
        model.isSubmitted && !widget.passwordValidator.isValid(model.password);

    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
          labelText: "Password",
          enabled: model.isLoading == false,
          errorText: showErrorText ? widget.invalidPasswordErrorText : null),
      textInputAction: TextInputAction.done,
      onChanged: (passwd) => widget.bloc.updateWith(password: passwd),
      obscureText: true,
    );
  }

  Future<void> _submitForm() async {
    try {
      await widget.bloc.submitForm();

      Navigator.of(context).pop();
    } on PlatformException catch (ex) {
      print(ex.toString());

      PlatformExceptionAlertDialog(
        title: "Sign in failed",
        exception: ex,
      ).show(context);
    }
  }

  void _toggleFormType(EmailSignInModel model) {
    widget.bloc.updateWith(
      email: '',
      password: '',
      formType: model.formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn,
      isSubmitted: false,
      isLoading: false,
    );

    _emailController.clear();
    _passwordController.clear();
  }

  void _emailEditingComplete(EmailSignInModel model) {
    final newFocus = widget.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;

    FocusScope.of(context).requestFocus(newFocus);
  }
}
