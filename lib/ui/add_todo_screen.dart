import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
} //for release branch

class _AddTodoScreenState extends State<AddTodoScreen> {
  String? _title = "";
  final List<String> categories = ["Work", "Study", "Groceries", "Personal", "Other"];
  String selectedCategory = "Work";

  void _backToMain() {
    context.pop(true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Todo"),),
      body: Column(
        spacing: 16.0,
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(16.0),
            child: 
            TextField(
              onChanged: (value) => _title = value,
              decoration: InputDecoration(
                labelText: "Title",
                 hintText: "eg. Study for exam",
                 border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0)
                 ),
                 focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0)
                 ),
                 prefixIcon: Icon(Icons.edit)
                 ),
            ),
          ),
          SizedBox(height: 16.0,),
          Text("Select Category", style: TextStyle(fontWeight: FontWeight.bold),),
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
               borderRadius: BorderRadius.circular(8)
               ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category)
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                 )
              ),
          ),
          SizedBox(height: 16.0,),
          FilledButton(
            onPressed: _backToMain, 
            child: Text("Add Todo")
            )
        ],
      ),
    );
  }
}