import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stride/data/model/todo.dart';
import 'package:stride/data/repo/todo_repo_sqlite.dart';

class UpdateTodoScreen extends StatefulWidget {
  final String id;
  const UpdateTodoScreen({super.key, required this.id});

  @override
  State<UpdateTodoScreen> createState() => _UpdateTodoScreenState();
}

class _UpdateTodoScreenState extends State<UpdateTodoScreen> {
  final repo = TodoRepoSqlite();
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = "Work";
  final List<String> categories = ["Work", "Study", "Groceries", "Personal", "Other"];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodo();
  }

  void _loadTodo() async {
    print("Loading todo with ID: ${widget.id}");

    final todo = await repo.getTodoById(int.parse(widget.id));

    if(todo != null) {
      setState(() {
        _titleController.text = todo.title;
        _selectedCategory = todo.category;
        _isLoading = false;
      });
    } else {
      print("Todo not found in database!");
    }
  }

  void _updateTodo() async {
    await repo.updateTodo(Todo(
      id: int.parse(widget.id),
      title: _titleController.text,
      category: _selectedCategory,
    ));
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text("Edit Text"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Update your task details", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Text Title",
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
            SizedBox(height: 24.0),
            Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.0,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat))).toList(), 
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  )
                ),
            ),
            SizedBox(height: 40.0),
            SizedBox(
              height: 55.0,
              child: FilledButton.icon(
                onPressed: _updateTodo,
                icon: Icon(Icons.save), 
                label: Text("Update Task"),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}