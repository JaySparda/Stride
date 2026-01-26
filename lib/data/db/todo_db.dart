import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stride/data/model/todo.dart';
import 'package:path_provider/path_provider.dart';

class TodoDb {
  static final TodoDb _instance = TodoDb.internal();
  TodoDb.internal();

  factory TodoDb() {
    return _instance;
  }

  Future<void> _createTables(Database db) async {
    await db.execute("""
      CREATE TABLE ${Todo.TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
""");
  }

  Future<Database> _openDb() async {
    final dir = await getApplicationCacheDirectory();
    final dbPath = join(dir.path, "todo_data.db");

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) => _createTables(db),
    );
  }

  Future<List<Map<String, dynamic>>> getAllTodo() async {
    final db = await _openDb();
    return db.query(Todo.TABLE_NAME, orderBy: "id");
  }

  Future<int> createTodo(Todo todo) async {
    final db = await _openDb();
    return db.insert(
      Todo.TABLE_NAME,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTodoById(int id) async {
    final db = await _openDb();
    return db.query(Todo.TABLE_NAME, where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await _openDb();
    return db.update(
      Todo.TABLE_NAME,
      todo.toMap(),
      where: "id = ?",
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _openDb();
    return db.delete(Todo.TABLE_NAME, where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateTodoStatus(int id, int status) async {
    final db = await _openDb();
    return await db.update(
      Todo.TABLE_NAME, 
      {'isCompleted': status},
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
