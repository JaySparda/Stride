import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stride/navigation/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
@override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp.router(
          title: 'Stride',
          themeMode: mode, 
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F)),
          ),
          routerConfig: GoRouter(
            initialLocation: Navigation.initial,
            routes: Navigation.routes,
          ),
        );
      },
    );
  }
}
