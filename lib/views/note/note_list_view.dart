import 'package:flutter/material.dart';
import 'package:mypersonalnote/services/crud/note_services.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallBak = void Function(DatabaseNote notes);

class NoteListView extends StatelessWidget {
  const NoteListView(
      {super.key, required this.onDeletedNote, required this.notes});

  final DeleteNoteCallBak onDeletedNote;
  final List<DatabaseNote> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
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
