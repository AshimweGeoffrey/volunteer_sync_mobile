import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'package:volunteer_sync/presentation/screens/points_rewards_screen.dart';
import 'presentation/screens/qr_code_screen.dart';
import 'presentation/screens/about_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const VolunteerSyncApp());
}

class VolunteerSyncApp extends StatelessWidget {
  const VolunteerSyncApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Volunteer Sync',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/points_rewards': (context) => const PointsRewardsScreen(),
        '/qr_code': (context) => const QRCodeScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
