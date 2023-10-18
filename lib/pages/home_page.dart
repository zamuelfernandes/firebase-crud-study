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
    TextEditingController? controller,
    String? title,
    required void Function()? actionPressed,
    required String actionText,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        actionsPadding: const EdgeInsets.all(20),
        content: title == null
            ? TextField(
                controller: controller,
              )
            : Text(
                title,
                textAlign: TextAlign.center,
              ),
        actions: [
          ElevatedButton(
            onPressed: actionPressed,
            child: Text(actionText),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'NOTES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: firestoreService.readNotes(),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
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
                      IconButton(
                        onPressed: () {
                          openNoteBox(
                            title: 'Dele this Note?\n(Click out to Escape)',
                            actionPressed: () {
                              firestoreService.deleteNote(
                                docID: documentID,
                              );
                              Navigator.pop(context);
                            },
                            actionText: 'Delete',
                          );
                        },
                        icon: const Icon(Icons.delete_forever),
                      ),
                    ],
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
              firestoreService.createNote(
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
