import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmora/screens/product_list_screen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations for better performance
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Enable memory optimizations for release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {}; // Disable debug prints
    PaintingBinding.instance.imageCache.maximumSize = 100; // Limit image cache size
  }
  
  // Set system UI overlay style for better appearance
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          color: Color(0xFF1E88E5),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: TextTheme(
          // Pre-define text styles for consistency and performance
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          labelMedium: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: ProductListScreen(),
    );
  }
}
