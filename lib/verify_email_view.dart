import 'package:flutter/material.dart';
import 'package:mypersonalnote/constant/routes.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text(
              "we've sent your a verification email, pls open to continue"),
          const Text(
              "if your haven't receive an email, pls click on the link below to resend"),
          TextButton(
            onPressed: () async {
              AuthServices.firebase().sendEmailVerification();

              if (!mounted) return;
            },
            child: const Text('Send email Verification'),
          ),
          TextButton(
            onPressed: () async {
              await AuthServices.firebase().logOut();
              if (!mounted) return;

              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
