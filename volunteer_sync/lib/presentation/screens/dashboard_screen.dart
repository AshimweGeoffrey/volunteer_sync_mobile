import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/volunteer_stats_card.dart';
import '../widgets/upcoming_event_card.dart';
import '../widgets/custom_drawer.dart';
import 'notification_screen.dart';
import 'map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardHomeScreen(),
      const NotificationScreen(),
      const MapScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Volunteer Sync'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.pushNamed(context, '/qr_code');
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Map',
              ),
            ],
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHomeScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Sarah!',
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your volunteering journey continues',
              style: AppTheme.captionStyle,
            ),
            const SizedBox(height: 24),
            const VolunteerStatsCard(
              hoursCompleted: 42,
              eventsAttended: 8,
              pointsEarned: 560,
            ),
            const SizedBox(height: 24),
            const Text(
              'Upcoming Events',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 12),
            UpcomingEventCard(
              title: 'City Park Cleanup',
              date: 'March 15, 2025',
              time: '9:00 AM - 12:00 PM',
              location: 'Central City Park',
              imageUrl: 'assets/images/park_cleanup.jpg',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            UpcomingEventCard(
              title: 'Food Bank Distribution',
              date: 'March 21, 2025',
              time: '2:00 PM - 5:00 PM',
              location: 'Community Center',
              imageUrl: 'assets/images/food_bank.jpg',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'Impact Overview',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 12),
            _buildImpactCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildImpactItem(
                  icon: Icons.nature_people,
                  color: AppTheme.accentGreenColor,
                  value: '120',
                  label: 'Trees Planted',
                ),
                _buildImpactItem(
                  icon: Icons.people,
                  color: AppTheme.accentBlueColor,
                  value: '85',
                  label: 'People Helped',
                ),
                _buildImpactItem(
                  icon: Icons.pets,
                  color: AppTheme.primaryColor,
                  value: '32',
                  label: 'Animals Saved',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: AppTheme.textPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                elevation: 0,
              ),
              child: const Text('View Full Impact Report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle,
        ),
      ],
    );
  }
}
