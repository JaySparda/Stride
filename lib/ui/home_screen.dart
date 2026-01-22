import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stride/data/model/todo.dart';
import 'package:stride/data/repo/todo_repo_sqlite.dart';
import 'package:stride/navigation/navigation.dart';
import 'package:stride/ui/add_todo_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: Icon(Icons.add),
        ),
      appBar: AppBar(
        title: Text("Stride"),
        centerTitle: true,
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
          FutureBuilder<List<Todo>>(
            future: repo.getAllTodo(),
             builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final todos = snapshot.data?? [];

              return todos.isEmpty 
              ? const Center(child: Text("No Tasks Yet", style: TextStyle(fontSize: 24),)) :
              ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) => TodoItem(
                  todo: todos[index],
                  onClickItem: (todo) => _navigateToUpdate(todo.id!)
                   ),
              );
             }
             ),
          Center(
            child: Text("Completed Todos", style: TextStyle(fontSize: 24)),
          ),
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
  const TodoItem({super.key,required this.todo, required this.onClickItem});

  final Todo todo;
  final Function(Todo) onClickItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClickItem(todo),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.title),
            SizedBox(height: 10.0,),
            Text("Category: ${todo.category}")
          ],
        ),
        )
      ),
    );
  }
}
