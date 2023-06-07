import 'package:flutter/material.dart';
import 'package:mypersonalnote/enum/menu_action.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/services/crud/note_services.dart';

import '../constant/routes.dart';

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
    _noteServices!.open();
    super.initState();
  }

  @override
  void dispose() {
    _noteServices = NotesServices();
    _noteServices!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Home'),
        actions: [
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
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _noteServices!.allNote,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Text('Waiting for all notes');
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
