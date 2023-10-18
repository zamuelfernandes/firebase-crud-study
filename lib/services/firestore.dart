import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //CREATE
  Future<void> addNote({required String note}) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  //READ
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: false).snapshots();

    return notesStream;
  }

  //UPDATE
  Future<void> updateNote({required String docID, required String newNote}) {
    return notes.doc(docID).update(
      {
        'note': newNote,
        'timestamp': Timestamp.now(),
      },
    );
  }

  //DELETE
}
