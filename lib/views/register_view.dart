import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

import 'package:mypersonalnote/constant/routes.dart';
import 'package:mypersonalnote/services/auth/auth_exception.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/utilities/show_error_dialog.dart';

class Registerview extends StatefulWidget {
  const Registerview({super.key});

  @override
  State<Registerview> createState() => _RegisterviewState();
}

class _RegisterviewState extends State<Registerview> {
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
        title: const Text('Register'),
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
                await AuthServices.firebase().createUser(
                  email: email,
                  password: password,
                );

                AuthServices.firebase().currentUser;
                AuthServices.firebase().sendEmailVerification;
                if (!mounted) return;
                Navigator.of(context).pushNamed(
                  verifyEmailRoute,
                );
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'user not found',
                );
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  'weak password',
                );
              } on EmailAlreadInUseAuthException {
                await showErrorDialog(
                  context,
                  'email already in use',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'fail to register',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              AuthServices.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('already Registered?, Login here!'),
          ),
        ],
      ),
    );
  }
}
