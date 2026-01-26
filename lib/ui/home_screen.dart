import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stride/data/model/todo.dart';
import 'package:stride/data/repo/todo_repo_sqlite.dart';
import 'package:stride/navigation/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = TodoRepoSqlite();
  List<Todo> todos = [];
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  int get _pendingCount => todos.where((t) => t.isCompleted == 0).length;

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(microseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _refresh() async {
    final data = await repo.getAllTodo();
    setState(() {
      todos = data;
    });
  }

  void _navigateToAdd() async {
    final refresh = await context.pushNamed(Screen.add.name);

    if(refresh == true) {
      _refresh();
    }
  }

  void _navigateToUpdate(int id) async {
    final refresh = await context.pushNamed(
      Screen.update.name,
      pathParameters: {"id": id.toString()}
      );

      if(refresh == true) {
        _refresh();
      }
  }

Future<bool?> _showDeleteDialog(Todo todo) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Delete"), // Fixed spelling: Confirm
      content: Text("Are you sure you want to delete '${todo.title}'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("CANCEL"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("DELETE"),
        ),
      ],
    ),
  );
}
  Widget _buildFilteredList(int status) {
    return FutureBuilder<List<Todo>>(
      future: repo.getAllTodo(), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTasks = snapshot.data?? [];

        final filteredList = allTasks.where((t) => t.isCompleted == status).toList();

        if(filteredList.isEmpty) {
          return Center(
            child: Text(
              status == 0 ? "No Pending Tasks" : "No Completed Tasks",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final todo = filteredList[index];

            return Dismissible(
              key: Key("todo_${todo.id}"),
              direction: DismissDirection.horizontal,

              secondaryBackground: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.delete, color: Colors.white,),
              ), 

              background: Container(
                color: status == 0 ? Colors.green : Colors.orange,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20.0),
                child: Icon(
                  status == 0 ? Icons.check : Icons.undo,
                  color: Colors.white,
                ),
              ),

              confirmDismiss: (direction) async {
                if(direction == DismissDirection.endToStart) {
                  return await _showDeleteDialog(todo);
                }
                return true;
              },

              onDismissed: (direction) async {
                if(direction == DismissDirection.startToEnd) {
                  int newStatus = status == 0 ? 1 : 0;
                  await repo.updateTodoStatus(todo.id!, newStatus);

                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(status == 0 ? "Task Completed!" : "Task Restored!"),
                        duration: Duration(milliseconds: 800),
                      )
                    );
                  }
                } else {
                  await repo.deleteTodo(todo.id!);
                }
                _refresh();
              },
              child: TodoItem(
                todo: todo, 
                onClickItem: (todo) => _navigateToUpdate(todo.id!), 
                onToggleComplete: (todo) async {
                  int newStatus = todo.isCompleted == 1 ? 0 : 1;
                  await repo.updateTodoStatus(todo.id!, newStatus);
                  _refresh(); 
                }
              )
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: Icon(Icons.add),
        ),
      appBar: AppBar(
        title: Column(
          children: [
            Text("Stride", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
            "$_pendingCount tasks remaining",
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            )
          ],
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(Screen.profile.name);
            },
            icon: Icon(Icons.account_circle_outlined))
        ],),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildFilteredList(0),
          _buildFilteredList(1)
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'In Progress'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
        ],
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  const TodoItem({super.key,required this.todo, required this.onClickItem, required this.onToggleComplete,});

  final Todo todo;
  final Function(Todo) onClickItem;
  final Function(Todo) onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final bool isDone = todo.isCompleted == 1;

    return ListTile(
      onTap: () => onClickItem(todo),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: Checkbox(
        value: isDone, 
        onChanged: (val) => onToggleComplete(todo),
        shape: CircleBorder(),
        activeColor: Colors.green,
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isDone ? Colors.grey : Colors.black87,
        ),
      ),
      subtitle:  Text(
        todo.category,
        style: TextStyle(
          color: isDone ? Colors.grey.shade400 : Colors.blueGrey,
        )
      ),
    );
  }
}
