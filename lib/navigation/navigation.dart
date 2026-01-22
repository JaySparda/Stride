import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:stride/ui/add_todo_screen.dart';
import 'package:stride/ui/home_screen.dart';
import 'package:stride/ui/profile_screen.dart';
import 'package:stride/ui/update_todo_screen.dart';

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
    ),
    GoRoute(
      path: "/update/:id",
      name: Screen.update.name,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return UpdateTodoScreen(id: id);
      }
    ),
    GoRoute(
      path: "/profile",
      name: Screen.profile.name,
      builder: (context, state) => const ProfileScreen()),
  ];
}

enum Screen { home, profile, add, update }
