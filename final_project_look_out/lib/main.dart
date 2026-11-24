import 'package:flutter/material.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';

// Theme configuration
import './app/themes/app_theme.dart';

// Pages
import './features/splash/splash_screen.dart';

void main() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCIJX5WKPzb0bXQ0-3-rsIGsKavX75idps",
      appId: "1:782818241515:web:81ec4ded641785c24707ae",
      messagingSenderId: "782818241515",
      projectId: "lookout-37180"
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LookOut!',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
