import 'package:flutter/material.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/services/crud/note_services.dart';
import 'package:mypersonalnote/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  // make some late declaration so that when the note view is tapped on add note, it can dispaly the list of notes and create fileds
  DatabaseNote? _note;
  late final NotesServices _notesServices;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesServices = NotesServices();
    _textController = TextEditingController();
    super.initState();
  }

// create a function that update the database each time a text is entered in the text field
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    // update our current notes upon text changes
    final text = _textController.text;
    await _notesServices.updateNote(note: note, text: text);
  }

// set up text controller listerner to add and remove listener
  void _setupTextControllerListerner() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

// create a function that create a new note as shown below
  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    // this function update the already existed note
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    // be sure the logged in user has an email
    // the '!' means that compulsorily there must be an existing user and with required email
    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email;
    final owner = await _notesServices.getUser(email: email);
    final newNote = await _notesServices.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

// create a function to invoke _noteServices.deleteNote if the note is empty
  void _deleteNoteIfNotEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesServices.deleteNote(id: note.id);
    }
  }

  // create a function that allows a user to automatically save a note if goes out of the note field
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesServices.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfNotEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('new notes'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              debugPrint("REACH HERE ${snapshot.data.toString()}");
// remove the _note.snapshot as List
              _setupTextControllerListerner();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter your text here',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
