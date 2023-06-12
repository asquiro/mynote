import 'package:flutter/material.dart';
import 'package:mypersonalnote/services/cloud/cloud_note.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallBak = void Function(CloudNote notes);

class NoteListView extends StatelessWidget {
  const NoteListView({
    super.key,
    required this.onDeletedNote,
    required this.notes,
    required this.onTap,
  });

  final NoteCallBak onDeletedNote;
  final NoteCallBak onTap;
  final Iterable<CloudNote> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeletedNote(note);
              }
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        );
      },
    );
  }
}
