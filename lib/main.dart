import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather_app/auth/homepage.dart';
import 'package:weather_app/auth/login.dart';
import 'package:weather_app/auth/signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pinkAccent,
      ),
      initialRoute: '/login',
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/weather': (context) => const HomePage(),
      },
    );
  }
}
