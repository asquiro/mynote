import 'package:flutter/material.dart';
import 'package:mypersonalnote/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'sharing',
    content: 'you cannot share empty note',
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
