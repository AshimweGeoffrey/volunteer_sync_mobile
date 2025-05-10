import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Volunteer Sync',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Our Mission',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Volunteer Sync aims to connect passionate volunteers with meaningful opportunities to make a difference in their communities. Our platform makes volunteer management simple, efficient, and rewarding for both volunteers and organizations.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Features',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Easy event registration and check-in'),
            _buildFeatureItem('Track volunteer hours and achievements'),
            _buildFeatureItem('Earn points and rewards for your contributions'),
            _buildFeatureItem('Find volunteering opportunities near you'),
            _buildFeatureItem('Connect with like-minded volunteers'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.accentGreenColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
