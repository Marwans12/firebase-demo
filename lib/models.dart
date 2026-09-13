import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String title;
  String category;
  String path;
  String content;

  Note({
    required this.title,
    required this.category,
    required this.path,
    required this.content,
  });

  factory Note.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {
    final data = snapshot.data();
    return Note(
      title: data?['title'],
      category: data?['category'],
      path: data?['path'],
      content: data?['content'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'path': path,
      'content': content,
    };
  }
}

