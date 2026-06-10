import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2E),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.orange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardColor: const Color(0xFF2C2C2E),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
