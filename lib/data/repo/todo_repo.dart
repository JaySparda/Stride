import 'package:stride/data/model/todo.dart';

abstract class TodoRepo {
  void add(Todo todo);
  List<Todo> getAllTodo();
  Todo? getTodoById(int id);
  void delete(int id);
  void update(Todo todo, int id);
  void updateStatus(int id, int status);
}
