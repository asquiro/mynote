import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:developer' as devtools show log;

import 'package:mypersonalnote/services/auth/auth_exception.dart';

import 'package:mypersonalnote/services/auth/bloc/auth_bloc.dart';
import 'package:mypersonalnote/services/auth/bloc/auth_event.dart';
import 'package:mypersonalnote/services/auth/bloc/auth_state.dart';
import 'package:mypersonalnote/utilities/dialogs/error_dialog.dart';
import 'package:mypersonalnote/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closedialog = _closeDialogHandle;
          if (!state.isLoading && closedialog != null) {
            closedialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closedialog == null) {
            _closeDialogHandle = showloadingDialog(
              context: context,
              text: 'loading....',
            );
          }
          if (state is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User not Found');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
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
              decoration: const InputDecoration(
                hintText: 'enter your email address',
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'enter your password',
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                      AuthEventLogIn(email, password),
                    );
              },
              child: const Text(
                'Login',
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventShouldRegisterUser(),
                    );
              },
              child: const Text(
                'Not Registered?, pls Register here!',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
