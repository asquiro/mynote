import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef CloseDialog = void Function();

CloseDialog showloadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(text),
      ],
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dialog,
    barrierDismissible: false,
  );
  return () => Navigator.of(context).pop();
}
