import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            accountName: const Text('Sarah Johnson'),
            accountEmail: const Text('sarah.johnson@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.primaryColor),
                  title: const Text('My Profile'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star, color: AppTheme.primaryColor),
                  title: const Text('Points & Rewards'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/points_rewards');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: AppTheme.primaryColor),
                  title: const Text('Activity History'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.update, color: AppTheme.primaryColor),
                  title: const Text('Updates'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: AppTheme.primaryColor),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
