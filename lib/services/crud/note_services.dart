import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NotesServices {
  Database? _db;

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOpenorThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(noteTable, {
      isSyncedWithCloudColumn: 0,
      textColumn: text,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    }
    return await getNote(id: note.id);
  }

  Future<Iterable<DatabaseNote>> getAllNote() async {
    final db = _getDatabaseOpenorThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteList) => DatabaseNote.fromRow(noteList));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOpenorThrow();
    final dbNote = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);
    if (dbNote.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(dbNote.first);
    }
  }

  Future<int> deleteAllNote() async {
    final db = _getDatabaseOpenorThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOpenorThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOpenorThrow();

    // be sure that the actually user is grapped from the firebase
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';

    // create note
    final noteId = await db.insert(
      noteTable,
      {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1},
    );
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOpenorThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Database _getDatabaseOpenorThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

// to delete user table, execute the following code as shown below
  Future<void> deleteAUser({required String email}) async {
    final db = _getDatabaseOpenorThrow();
    final deletedCount =
        await db.delete(userTable, where: 'email =?', whereArgs: [
      email.toLowerCase(),
    ]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

// to create user table, execute the following code as shown below
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOpenorThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExist();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final getPath = await getApplicationDocumentsDirectory();
      final dbPath = join(getPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // CREATE USER TABLE AND GRAP THE CODE FROM THE SQLITE AND REPLACE AFTER THE THREE QUOTE

      await db.execute(createUserTable);
// CREATE NOTE TABLE AND GRAP THE CODE FROM THE SQLITE AND REPLACE AFTER THE THREE QUOTE

      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirector();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, Text = $text, IsSyncedWithCloud = $isSyncedWithCloud,';
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

const dbName = 'note.db';
const noteTable = 'note';
const userTable = 'user';
const emailColumn = 'email';
const idColumn = 'id';
const userIdColumn = 'userId';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'isSyncedWithCloud';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email"	INTEGER NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
); 

''';
