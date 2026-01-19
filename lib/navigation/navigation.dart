import 'package:go_router/go_router.dart';
import 'package:stride/ui/home_screen.dart';

class Navigation {
  static const initial = "/home";
  static final routes = [
    GoRoute(
      path: "/home",
      name: Screen.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
  ];
}

enum Screen { home, profile, add, update }
