import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride/data/model/todo.dart';

class TodoRepoFirebase {
String? _userId;

  Future<String> getUserId() async {
    if (_userId == null) {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_unique_id');
      
      if (_userId == null) {
        _userId = _generateUserId();
        await prefs.setString('user_unique_id', _userId!);
      }
    }
    return _userId!;
  }

  String _generateUserId() {
    final random = Random();
    String id = "";
    for (int i = 0; i < 9; i++) {
      id += random.nextInt(10).toString();
    }
    return id;
  }
  
  void refreshUser() {
    _userId = null;
  }
  Future<CollectionReference> _getDb() async {
    final id = await getUserId();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('todos');
  }

  Future<void> syncTodo(Todo todo) async {
    final db = await _getDb();
    return await db.doc(todo.id.toString()).set(todo.toMap());
  }

  Future<List<Todo>> fetchAllTodoFromCloud() async {
    final db = await _getDb();
    final snapshot = await db.get();
    return snapshot.docs.map((doc) {
      return Todo.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> deleteFromCloud(int id) async {
    final db = await _getDb();
    return await db.doc(id.toString()).delete();
  }

  Future<void> updateStatusFromCloud(int id, int status) async {
    final db = await _getDb();
    return await db.doc(id.toString()).update({'isCompleted': status});
  }

  Future<void> updateFromCloud(Todo todo) async {
    final db = await _getDb();
    return await db.doc(todo.id.toString()).update(todo.toMap());
  }
}