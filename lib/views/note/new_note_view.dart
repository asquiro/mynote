import 'package:flutter/material.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/services/crud/note_services.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  // make some late declaration so that when the note view is tapped on add note, it can dispaly the list of notes and create fileds
  DatabaseNote? _note;
  late final NotesServices _notesServices;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _notesServices = NotesServices();
    _textController = TextEditingController();
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
  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    // be sure the logged in user has an email
    // the '!' means that compulsorily there must be an existing user and with required email
    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesServices.getUser(email: email);
    return await _notesServices.createNote(owner: owner);
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
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              debugPrint("REACH HERE ${snapshot.data.toString()}");
              _note = snapshot.data;
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
