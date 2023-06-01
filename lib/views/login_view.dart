import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

import 'package:mypersonalnote/constant/routes.dart';
import 'package:mypersonalnote/services/auth/auth_exception.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: 'enter your email address'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'enter your password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthServices.firebase().logIn(
                  email: email,
                  password: password,
                );

                final user = AuthServices.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  //user is emailVerified
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    noteRoute,
                    (route) => false,
                  );
                } else {
                  //user is not emailVerified. return to emailVerification page
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  noteRoute,
                  (route) => false,
                );
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'user not found',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  'wrong password',
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'invalid email address',
                );
              } on GenericAuthException {
                await showErrorDialog(context, 'Authentication Error');
              }
            },
            child: const Text(
              'Login',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text(
              'Not Registered?, pls Register here!',
            ),
          ),
        ],
      ),
    );
  }
}
