import 'package:flutter/material.dart';
import 'package:farmora/screens/login_screen.dart';
import 'package:farmora/screens/signup_screen.dart';

void main() {
  runApp(FarmoraApp());
}

class FarmoraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmora',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
