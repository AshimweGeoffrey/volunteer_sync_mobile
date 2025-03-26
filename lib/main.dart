import 'package:flutter/material.dart';
import 'package:farmora/screens/login_screen.dart';
import 'package:farmora/screens/signup_screen.dart';
import 'package:farmora/screens/welcome_screen.dart';
import 'package:farmora/screens/dashboard_screen.dart';
import 'package:farmora/screens/calculator_screen.dart';
import 'package:farmora/screens/product_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FarmoraApp());
}

class FarmoraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E886E),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E886E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE3F2FD),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        useMaterial3: true,
      ),
      // Starting with welcome screen
      home: WelcomeScreen(),
      
      // Routes without const keywords
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/calculator': (context) => CalculatorScreen(),
        '/products': (context) => ProductListScreen(),
      },
    );
  }
}
