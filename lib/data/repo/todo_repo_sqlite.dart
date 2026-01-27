import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride/data/db/todo_db.dart';
import 'package:stride/data/model/todo.dart';
import 'package:stride/data/repo/todo_repo_firebase.dart';

class TodoRepoSqlite {
  final db = TodoDb();
  static final TodoRepoSqlite _instance = TodoRepoSqlite._internal();
  TodoRepoSqlite._internal();
  final cloudRepo = TodoRepoFirebase();
  bool cloudSyncEnable = true;

  factory TodoRepoSqlite() {
    return _instance;
  }

  Future<bool> _shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('cloud_sync') ?? false;
  }

  Future<List<Todo>> getAllTodo() async {
    final mapOfTask = await db.getAllTodo();
    return mapOfTask
        .map((Map<String, dynamic> value) => Todo.fromMap(value))
        .toList();
  }

  Future<Todo?> getTodoById(int id) async {
    final List<Map<String, dynamic>> map = await db.getTodoById(id);
    if (map.isNotEmpty) {
    return Todo.fromMap(map[0]);
    }

    return null;
  }

  Future<int> addTodo(Todo todo) async {
    int id = await db.createTodo(todo);

    if(await _shouldSync()) {
      final todoWithId = Todo(
        id: id,
        title: todo.title, 
        category: todo.category,
        isCompleted: todo.isCompleted
        );
      await cloudRepo.syncTodo(todoWithId);
    }
    return id;
  }

  Future<int> deleteTodo(int id) async {
    int result = await db.delete(id);

    if(await _shouldSync()) {
      await cloudRepo.deleteFromCloud(id);
    }

    return result;
  }

  Future<int> updateTodo(Todo todo) async {
    int result = await db.updateTodo(todo);

    if(result > 0 && await _shouldSync()) {
      await cloudRepo.updateFromCloud(todo);
    }
    return result;
  }

  Future<void> updateTodoStatus(int id, int status) async {
    await db.updateTodoStatus(id, status);

    if(await _shouldSync()) {
      await cloudRepo.updateStatusFromCloud(id, status);
    }
  }
}
