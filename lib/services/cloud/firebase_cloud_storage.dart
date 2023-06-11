import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mypersonalnote/services/cloud/cloud_note.dart';
import 'package:mypersonalnote/services/cloud/cloud_storage_constants.dart';
import 'package:mypersonalnote/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

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
