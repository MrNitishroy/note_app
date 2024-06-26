import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controller/authController.dart';
import 'package:note_app/model/model.dart';

class NoteController extends GetxController {
  TextEditingController addnote = TextEditingController();

  final noteList = <NoteModel>[].obs;

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final AuthController authController = Get.find();

  @override
  Future<void> onInit() async {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        getNote();
      } else {
        noteList.clear();
      }
    });
    if (auth.currentUser != null) {
      await getNote();
    }
  }

  void showAddNoteDialog() {
    Get.defaultDialog(
      title: "Add Note",
      content: TextFormField(
        controller: addnote,
        decoration: InputDecoration(
          hintText: "Enter your note",
        ),
      ),
      textConfirm: "Add",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (addnote.text.isNotEmpty) {
          addNote();
          addnote.clear();
          Get.back();
        } else {
          Get.snackbar("Error", "Note cannot be empty");
        }
      },
      onCancel: () {
        addnote.clear();
      },
    );
  }

  Future<void> addNote() async {
    var notemodel = NoteModel(
      note: addnote.text,
      userName: authController.userName.text,
      noteI: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("note")
        .add(notemodel.toJson());

    Get.snackbar("To do Added", "To do Added to Firestore",
        backgroundColor: Colors.green);
  }

  Future<void> getNote() async {
    try {
      noteList.clear();
      var data = await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("note")
          .get();

      for (var note in data.docs) {
        noteList.add(NoteModel.fromJson(note.data()));
      }
    } catch (ex) {
      Get.snackbar("Error to get note", ex.toString());
    }
  }
}
