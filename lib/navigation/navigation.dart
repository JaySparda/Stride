import 'package:go_router/go_router.dart';
import 'package:stride/ui/add_todo_screen.dart';
import 'package:stride/ui/home_screen.dart';

class Navigation {
  static const initial = "/home";
  static final routes = [
    GoRoute(
      path: "/home",
      name: Screen.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: "/add",
      name: Screen.add.name,
      builder: (context, state) => const AddTodoScreen(),
      )
  ];
}

enum Screen { home, profile, add, update }
