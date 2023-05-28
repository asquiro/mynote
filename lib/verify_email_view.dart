import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mypersonalnote/constant/routes.dart';

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
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
              if (!mounted) return;
              Navigator.of(context).pushNamed(verifyEmailRoute);
            },
            child: const Text('Send email Verification'),
          ),
        ],
      ),
    );
  }
}
