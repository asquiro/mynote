import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

import 'package:mypersonalnote/constant/routes.dart';
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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
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
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  await showErrorDialog(
                    context,
                    'User not found',
                  );
                } else if (e.code == 'wrong-password') {
                  await showErrorDialog(
                    context,
                    'Invalid login Credentials',
                  );
                } else {
                  await showErrorDialog(context, 'Error: ${e.code}');
                }
                // devtools.log(e.code);
              } catch (e) {
                await showErrorDialog(
                  context,
                  e.toString(),
                );
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
