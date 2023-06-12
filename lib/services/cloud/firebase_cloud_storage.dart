import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mypersonalnote/services/cloud/cloud_note.dart';
import 'package:mypersonalnote/services/cloud/cloud_storage_constants.dart';
import 'package:mypersonalnote/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection(
    'notes',
  );

// deleting note from cloudstore can be expressed as

  Future<void> deleteNotes({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotCreateNoteException();
    }
  }

// using cloudfirestorage to continuously synchronize our note changes to ur firebase
  Future<void> updateNotes({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update(
        {textFieldName: text},
      );
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  // a stream to grap all the changes made in the notes and syncronized directly to cloud
  Stream<Iterable<CloudNote>> allNotes({required String ownersUserId}) =>
      notes.snapshots().map(
            (event) => event.docs
                .map(
                  (doc) => CloudNote.fromSnapshot(doc),
                )
                .where(
                  (note) => note.ownerUserId == ownersUserId,
                ),
          );

  // a function to get all the notes and syncronized it to the cloudfirestore thats the database
  Future<Iterable<CloudNote>> getNotes({
    required String ownerUserID,
  }) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserID,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (docs) {
                return CloudNote(
                  documentId: docs.id,
                  ownerUserId: docs.data()[ownerUserIdFieldName] as String,
                  text: docs.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
