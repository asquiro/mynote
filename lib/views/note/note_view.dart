import 'package:flutter/material.dart';
import 'package:mypersonalnote/enum/menu_action.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/services/crud/note_services.dart';

import '../../constant/routes.dart';

class Noteview extends StatefulWidget {
  const Noteview({super.key});
  @override
  State<Noteview> createState() => _NoteviewState();
}

class _NoteviewState extends State<Noteview> {
  NotesServices? _noteServices;

  String get userEmail => AuthServices.firebase().currentUser!.email!;

  @override
  void initState() {
    _noteServices = NotesServices();
    super.initState();
  }

// lets override the dispose function for now so we wont be closing the databse when not expected
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
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuItem>(
            onSelected: (value) async {
              switch (value) {
                case MenuItem.logout:
                  final showLoging = await showLogDialog(context);
                  if (showLoging) {
                    await AuthServices.firebase().logOut();
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                    // Navigator.of(context).push(
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
      body: FutureBuilder(
          future: _noteServices!.getorCreateUser(email: userEmail),
          builder: (context, snapshot) {
            // debugPrint(" snapshot CONNECTION : ${snapshot.connectionState}");
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _noteServices!.allNote,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            debugPrint('print ${snapshot.data}');
                            final allNotes =
                                snapshot.data as List<DatabaseNote>;
                            return ListView.builder(
                              itemCount: allNotes.length,
                              itemBuilder: (context, index) {
                                final note = allNotes[index];
                                return ListTile(
                                  title: Text(
                                    note.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        default:
                          return const CircularProgressIndicator();
                      }
                    });
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}

Future<bool> showLogDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Comfirm you want to signout'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
