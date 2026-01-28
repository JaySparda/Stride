import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stride/data/model/todo.dart';

class TodoRepoFirebase {
  final CollectionReference _db = FirebaseFirestore.instance.collection('todos');

  Future<void> syncTodo(Todo todo) async {
    return await _db.doc(todo.id.toString()).set(todo.toMap());
  }

  Future<void> deleteFromCloud(int id) async {
    return await _db.doc(id.toString()).delete();
  }

  Future<void> updateStatusFromCloud(int id, int status) async {
    return await _db.doc(id.toString()).update({'isCompleted': status});
  }

  Future<void> updateFromCloud(Todo todo) async {
    return await _db.doc(todo.id.toString()).update(todo.toMap());
  }
}