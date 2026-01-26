import 'package:stride/data/db/todo_db.dart';
import 'package:stride/data/model/todo.dart';

class TodoRepoSqlite {
  final db = TodoDb();
  static final TodoRepoSqlite _instance = TodoRepoSqlite._internal();
  TodoRepoSqlite._internal();

  factory TodoRepoSqlite() {
    return _instance;
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
    return await db.createTodo(todo);
  }

  Future<int> deleteTodo(int id) async {
    return await db.delete(id);
  }

  Future<int> updateTodo(Todo todo) async {
    return await db.updateTodo(todo);
  }

  Future<void> updateTodoStatus(int id, int status) async {
    await db.updateTodoStatus(id, status);
  }
}
