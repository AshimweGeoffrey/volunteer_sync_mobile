// lib/presentation/screens/points_rewards_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PointsRewardsScreen extends StatelessWidget {
  const PointsRewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points & Rewards'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPointsCard(),
              const SizedBox(height: 20),
              const Text('Available Rewards', style: AppTheme.subheadingStyle),
              const SizedBox(height: 16),
              _buildRewardsList(),
              const SizedBox(height: 20),
              const Text('Your Badges', style: AppTheme.subheadingStyle),
              const SizedBox(height: 16),
              _buildBadgesGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentBlueColor, AppTheme.accentGreenColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Points',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            '560',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Container(
                  width: 280, // 56% progress (560/1000 points)
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const Text(
                'Next Goal: 1000',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList() {
    // Create a list of rewards with their properties
    final List<Map<String, dynamic>> rewards = [
      {'title': 'Free T-Shirt', 'points': '250 points', 'icon': Icons.card_giftcard, 'available': true},
      {'title': 'Coffee Voucher', 'points': '350 points', 'icon': Icons.local_cafe, 'available': true},
      {'title': 'Premium Event', 'points': '500 points', 'icon': Icons.event_available, 'available': true},
      {'title': 'Leadership Program', 'points': '1000 points', 'icon': Icons.emoji_events, 'available': false},
    ];
    
    return Column(
      children: rewards.map((reward) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: reward['available'] ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              child: Icon(reward['icon'], color: reward['available'] ? AppTheme.primaryColor : Colors.grey),
            ),
            title: Text(reward['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(reward['points']),
            trailing: ElevatedButton(
              onPressed: reward['available'] ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: reward['available'] ? AppTheme.primaryColor : Colors.grey,
              ),
              child: Text(reward['available'] ? 'Redeem' : 'Locked'),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadgesGrid() {
    // Create a list of badges with their properties
    final List<Map<String, dynamic>> badges = [
      {'name': 'First Timer', 'icon': Icons.star, 'color': Colors.amber, 'earned': true},
      {'name': 'Dedicated', 'icon': Icons.favorite, 'color': Colors.red, 'earned': true},
      {'name': 'Team Player', 'icon': Icons.people, 'color': AppTheme.accentBlueColor, 'earned': true},
      {'name': '5 Events', 'icon': Icons.event, 'color': Colors.green, 'earned': false},
      {'name': 'Eco Hero', 'icon': Icons.eco, 'color': AppTheme.accentGreenColor, 'earned': false},
      {'name': 'Leader', 'icon': Icons.workspace_premium, 'color': Colors.deepPurple, 'earned': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badge['earned'] ? badge['color'].withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge['earned'] ? badge['color'] : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(badge['icon'], color: badge['earned'] ? badge['color'] : Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              badge['name'],
              style: TextStyle(
                fontSize: 12,
                color: badge['earned'] ? AppTheme.textPrimaryColor : Colors.grey,
                fontWeight: badge['earned'] ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
