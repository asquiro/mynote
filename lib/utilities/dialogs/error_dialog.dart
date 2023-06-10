import 'package:flutter/material.dart';
import 'package:mypersonalnote/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'an error occured',
    content: text,
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
