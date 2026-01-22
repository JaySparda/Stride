  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
import 'package:stride/data/model/todo.dart';
import 'package:stride/data/repo/todo_repo_sqlite.dart';

  class AddTodoScreen extends StatefulWidget {
    const AddTodoScreen({super.key});

    @override
    State<AddTodoScreen> createState() => _AddTodoScreenState();
  }

  class _AddTodoScreenState extends State<AddTodoScreen> {
    final repo = TodoRepoSqlite();
    String? _title = "";
    final List<String> categories = ["Work", "Study", "Groceries", "Personal", "Other"];
    String selectedCategory = "Work";

    void _saveTask() async {
      if(_title == null || _title!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a task title")),
        );
        return;
      }

      final newTodo = Todo(
        title: _title!,
        category: selectedCategory,
        isCompleted: 0
      );

      await repo.addTodo(newTodo);
      
      if(mounted) {
      context.pop(true);
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Add Todo"),centerTitle: true,),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("What's in your mind?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.0),
              TextField(
                onChanged: (value) => _title = value,
                decoration: InputDecoration(
                  labelText: "Task Title",
                  prefixIcon: Icon(Icons.task_alt),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
              SizedBox(height: 24.0,),
              Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat)
                      )).toList(),
                     onChanged: (val) => setState(() => selectedCategory = val!),
                     )
                  ),
              ),
              SizedBox(height: 40.0,),
              SizedBox(
                height: 55.0,
                child: FilledButton.icon(
                  onPressed: _saveTask,
                  icon: Icon(Icons.add),
                  label: Text("Save Task", style: TextStyle(fontSize: 16.0)),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))
                  ),
                   ),
              )
            ],
          ),
        ),
      );
    }
  }