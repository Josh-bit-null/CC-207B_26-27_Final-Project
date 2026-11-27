import 'package:flutter/material.dart';
//firebase
import 'package:firebase_core/firebase_core.dart';

// Theme configuration
import './app/themes/app_theme.dart';

// Pages
import './features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  if (firebaseApiKey.isEmpty) {
    throw StateError(
      'FIREBASE_API_KEY is missing. Build or run with '
      '--dart-define-from-file=.env.json.',
    );
  }
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: firebaseApiKey,
      appId: "1:359574670183:android:47cc0c7a32f07b0fbebdc2",
      messagingSenderId: "359574670183",
      projectId: "lookout-cf9df"
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
