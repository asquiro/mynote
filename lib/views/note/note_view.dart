import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mypersonalnote/enum/menu_action.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/services/auth/bloc/auth_bloc.dart';
import 'package:mypersonalnote/services/auth/bloc/auth_event.dart';
import 'package:mypersonalnote/services/cloud/cloud_note.dart';
import 'package:mypersonalnote/services/cloud/firebase_cloud_storage.dart';

import 'package:mypersonalnote/utilities/dialogs/logout_dialog.dart';

import 'package:mypersonalnote/views/note/note_list_view.dart';

import '../../constant/routes.dart';

class Noteview extends StatefulWidget {
  const Noteview({super.key});
  @override
  State<Noteview> createState() => _NoteviewState();
}

class _NoteviewState extends State<Noteview> {
  FirebaseCloudStorage? _noteServices;

  String get userId => AuthServices.firebase().currentUser!.id;

  @override
  void initState() {
    _noteServices = FirebaseCloudStorage();
    super.initState();
  }

// lets override the dispose function for now so we wont be closing the databse when not suposed to
  // @override
  // void dispose() {
  //   _noteServices!.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuItem>(
            onSelected: (value) async {
              switch (value) {
                case MenuItem.logout:
                  final showLoging = await showLogoutDialog(context);
                  if (showLoging) {
                    if (!mounted) return;
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuItem>(
                  value: MenuItem.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _noteServices!.allNotes(
            ownersUserId: userId,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  debugPrint('print ${snapshot.data}');
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NoteListView(
                    onTap: (notes) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: notes,
                      );
                    },
                    onDeletedNote: (note) async {
                      await _noteServices!.deleteNotes(
                        documentId: note.documentId,
                      );
                    },
                    notes: allNotes,
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
