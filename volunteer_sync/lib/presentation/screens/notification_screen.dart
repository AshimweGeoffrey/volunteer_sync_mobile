import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildNotificationHeader(context, "Today"),
          _buildNotificationItem(
            context,
            title: "New Event Available",
            description: "Beach Cleanup has been scheduled for next weekend.",
            time: "2 hours ago",
            icon: Icons.event,
            iconColor: AppTheme.accentBlueColor,
          ),
          _buildNotificationItem(
            context,
            title: "Points Awarded",
            description: "You've received 75 points for your last event.",
            time: "5 hours ago",
            icon: Icons.star,
            iconColor: Colors.amber,
            isUnread: true,
          ),
          _buildNotificationHeader(context, "Yesterday"),
          _buildNotificationItem(
            context,
            title: "Thank You Note",
            description: "Central Community Center thanked you for your contribution.",
            time: "1 day ago",
            icon: Icons.favorite,
            iconColor: Colors.red,
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            title: "Badge Earned",
            description: "Congratulations! You've earned the 'Dedicated Volunteer' badge.",
            time: "1 day ago",
            icon: Icons.shield,
            iconColor: AppTheme.accentGreenColor,
          ),
          _buildNotificationHeader(context, "This Week"),
          _buildNotificationItem(
            context,
            title: "Event Reminder",
            description: "Don't forget about the Food Drive tomorrow at 9 AM.",
            time: "2 days ago",
            icon: Icons.calendar_today,
            iconColor: AppTheme.primaryColor,
          ),
          _buildNotificationItem(
            context,
            title: "New Role Available",
            description: "Apply for Event Coordinator role for the upcoming Community Festival.",
            time: "3 days ago",
            icon: Icons.work,
            iconColor: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isUnread ? iconColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
