import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, CollectionReference;
import 'package:flutter/material.dart';
import '../models.dart' show Category, Doc, Note;

class CircleAssetImage extends StatelessWidget {
  const CircleAssetImage({
    super.key,
    required this.name,
    this.size,
    this.padding,
    this.backgroundColor,
  });
  final double? size;
  final String name;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        height: size,
        width: size,
        clipBehavior: Clip.hardEdge,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(180),
          color: backgroundColor,
        ),
        child: Image.asset(name),
      ),
    );
  }
}

class ObsecuredTextFormField extends StatefulWidget {
  const ObsecuredTextFormField({
    super.key,
    required this.inputDecoration,
    required this.passwordController,
    this.validator,
  });
  final String? Function(String?)? validator;
  final InputDecoration inputDecoration;
  final TextEditingController passwordController;

  @override
  State<ObsecuredTextFormField> createState() => _ObsecuredTextFormFieldState();
}

class _ObsecuredTextFormFieldState extends State<ObsecuredTextFormField> {
  var isObsecured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: widget.inputDecoration.copyWith(
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isObsecured = !isObsecured;
            });
          },
          icon: Icon(isObsecured ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      controller: widget.passwordController,
      validator: widget.validator,
      obscureText: isObsecured,
    );
  }
}

class LoadingOverlay extends OverlayEntry {
  LoadingOverlay(this.context)
    : super(
        builder: (context) {
          return Container(
            color: const Color.fromARGB(108, 0, 0, 0),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
  final BuildContext context;
}

class Validators {
  Validators._();

  static String? emailValidator(String? email) {
    {
      if (email == null || email.isEmpty || !email.contains("@")) {
        return "Enter valid email address";
      }
      return null;
    }
  }

  static String? passwordValidator(String? password) {
    {
      if (password == null || password.isEmpty) {
        return "Password can not be empty";
      }
      if (password.length < 5) {
        return "Password must be at least 5 characters long";
      }
      return null;
    }
  }
}

class ConfirmDocDeletionDialog extends StatelessWidget {
  const ConfirmDocDeletionDialog({super.key, required this.deletedName});

  final String deletedName;

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return AlertDialog(
      title: Text("Confirm Deletion"),
      content: Text("Are you sure you want to delete '$deletedName'?"),
      actions: [
        Theme(
          data: ThemeData(
            colorScheme: ColorScheme.of(
              context,
            ).copyWith(primary: Colors.black87),
          ),
          child: TextButton(
            onPressed: () => navigator.pop(),
            child: Text("Cancel"),
          ),
        ),
        Theme(
          data: ThemeData(
            colorScheme: ColorScheme.of(context).copyWith(primary: Colors.red),
          ),
          child: TextButton(
            onPressed: () => navigator.pop(true),
            child: Text("Delete"),
          ),
        ),
      ],
    );
  }
}

class CollectionManager<T extends Doc> {
  CollectionManager(this.collectionReference);
  final docs = <T>[];
  final docsReferences = <T, DocumentReference<T>>{};
  final CollectionReference<T> collectionReference;

  Future<void> resyncDocs() async {
    docs.clear();
    docsReferences.clear();
    var fetchedDocs = (await collectionReference.get()).docs;
    for (var doc in fetchedDocs) {
      addIncoming(doc.data(), doc.reference);
    }
  }


  void addIncoming(T doc, DocumentReference<T> ref) {
    docs.add(doc);
    docsReferences[doc] = ref;
  }

  void deleteIncoming(T doc) {
    int i;
    for (i = 0; i < docs.length; i++) {
      if(doc.id == docs[i].id) {
        break;
      }
    }
    if (i >= docs.length) throw Exception("File is not in");
    var item = docs.removeAt(i);
    docsReferences.remove(item);
  }

  void add(T doc) async {
    assert(doc.id == null);
    // docs.add(doc);
    var newDocRef = collectionReference.doc();
    doc.id = newDocRef.id;
    // docsReferences[doc] = newDocRef;
    await newDocRef.set(doc);
  }

  void delete(T doc) async {
    var docReference = docsReferences[doc];
    // docsReferences.remove(doc);
    // docs.remove(doc);
    await docReference!.delete();
  }
}

class NotesCollectionManager extends CollectionManager<Note> {
  NotesCollectionManager(super.collectionReference);

  void update(
    Note note,
    {String? newTitle, String? newContent}
  ) async {
    //TODO: Implement categoryID update
    assert(newTitle != null || newContent != null);
    // note.title = newTitle ?? note.title;
    // note.content = newContent ?? note.content;
    // note.lastEditedTime = DateTime.now();
    var reference = super.docsReferences[note];
    await reference!.update({
      if (newTitle != null) "title": newTitle,
      if (newContent != null) "content": newContent,
      "lastEditedTime": DateTime.now()
    });
  }

  void updateIncoming(Note note) {
    int i;
    for(i = 0; i < docs.length; i++) {
      if(note.id == docs[i].id) {
        break;
      }
    }
    docs[i].title = note.title;
    docs[i].content = note.content;
    docs[i].lastEditedTime = note.lastEditedTime;
    docs[i].categoryID = note.categoryID;
  }
}

class CategoryCollectionManager extends CollectionManager<Category> {
  CategoryCollectionManager(super.collectionReference);

  void update(Category category, String newName) async {
    var reference = super.docsReferences[category];
    await reference!.update({"name": newName, "lastEditedTime": DateTime.now()});
  }

  void updateIncoming(Category category) {
    int i;
    for(i = 0; i < docs.length; i++) {
      if(category.id == docs[i].id) {
        break;
      }
    }
    docs[i].name = category.name;
    docs[i].lastEditedTime = category.lastEditedTime;
  }
}
