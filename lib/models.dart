import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Doc {
  Doc({this.id});
  String? id;
}

class Note extends Doc {
  String title;
  String categoryID;
  String content;
  DateTime lastEditedTime;
  final DateTime creationTime;

  Note({
    super.id,
    required this.title,
    this.content = "",
    required this.categoryID,
    DateTime? creationTime,
    DateTime? lastEditedTime,
  }) : creationTime = creationTime ?? DateTime.now(),
       lastEditedTime = lastEditedTime ?? DateTime.now() {
    assert(
      this.lastEditedTime.isAfter(this.creationTime) ||
          this.lastEditedTime.isAtSameMomentAs(this.creationTime),
    );
  }

  factory Note.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Note(
      id: data['id'],
      title: data['title'],
      content: data['content'],
      categoryID: data['category'],
      creationTime: (data['creationTime'] as Timestamp).toDate(),
      lastEditedTime: (data['lastEditedTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    assert(id != null);
    return {
      'id': id,
      'title': title,
      'category': categoryID,
      'content': content,
      'creationTime': creationTime,
      'lastEditedTime': lastEditedTime,
    };
  }
}

class Category extends Doc {
  String name;
  DateTime creationTime;
  DateTime lastEditedTime;

  Category({
    super.id,
    required this.name,
    DateTime? creationTime,
    DateTime? lastEditedTime,
  }) : creationTime = creationTime ?? DateTime.now(),
       lastEditedTime = lastEditedTime ?? DateTime.now() {
    assert(
      this.lastEditedTime.isAfter(this.creationTime) ||
          this.lastEditedTime.isAtSameMomentAs(this.creationTime),
    );
  }

  factory Category.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Category(
      id: data['id'],
      name: data['name'],
      creationTime: (data['creationTime'] as Timestamp).toDate(),
      lastEditedTime: (data['lastEditedTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    assert(id != null);
    return {
      'id': id,
      'name': name,
      'creationTime': creationTime,
      'lastEditedTime': lastEditedTime,
    };
  }
}
