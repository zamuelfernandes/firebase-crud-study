import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_study_app/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _createNoteController = TextEditingController();
  final TextEditingController _updateNoteController = TextEditingController();

  void openNoteBox({
    required TextEditingController controller,
    required void Function()? actionPressed,
    required String actionText,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: TextField(
          controller: controller,
        ),
        actions: [
          ElevatedButton(
            onPressed: actionPressed,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NOTES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String documentID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String noteText = data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: IconButton(
                    onPressed: () {
                      openNoteBox(
                        controller: _updateNoteController,
                        actionPressed: () {
                          firestoreService.updateNote(
                            docID: documentID,
                            newNote: _updateNoteController.text,
                          );

                          _createNoteController.clear();
                          Navigator.pop(context);
                        },
                        actionText: 'Update',
                      );
                    },
                    icon: const Icon(Icons.draw),
                  ),
                );
              },
            );
          } else {
            return const Text('No notes...');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNoteBox(
            controller: _createNoteController,
            actionText: 'Add',
            actionPressed: () {
              firestoreService.addNote(
                note: _createNoteController.text,
              );
              _createNoteController.clear();
              Navigator.pop(context);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
