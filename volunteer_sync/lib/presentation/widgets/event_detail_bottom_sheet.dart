import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/models/event.dart';

class EventDetailBottomSheet extends StatelessWidget {
  final VolunteerEvent event;

  const EventDetailBottomSheet({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Main content
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      expandedHeight: 200,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Event Image
                            event.imageUrl != null
                                ? Image.asset(
                                    event.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: _getCategoryColor(event.category).withOpacity(0.2),
                                    child: Icon(
                                      _getCategoryIcon(event.category),
                                      size: 80,
                                      color: _getCategoryColor(event.category),
                                    ),
                                  ),
                            
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.7, 1.0],
                                ),
                              ),
                            ),
                            
                            // Category badge
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(event.category),
                                      size: 16,
                                      color: _getCategoryColor(event.category),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.category.toString().split('.').last,
                                      style: TextStyle(
                                        color: _getCategoryColor(event.category),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Title at bottom
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    
                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Info
                            _buildInfoRow(Icons.calendar_today, 'Date', event.formattedDate),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.access_time, 'Time', event.formattedTime),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on, 'Location', event.location),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.people, 'Availability', 
                              '${event.spotsAvailable}/${event.spotsTotal} spots available',
                              valueColor: event.spotsAvailable > 0 ? Colors.green : AppTheme.primaryColor
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.star,
                              'Impact Points',
                              '${event.impactPoints} points',
                              valueColor: Colors.amber,
                            ),
                            
                            const Divider(height: 32),
                            
                            // Description
                            const Text(
                              'About This Event',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                height: 1.5,
                              ),
                            ),
                            
                            const Divider(height: 32),
                            
                            // Required Skills
                            const Text(
                              'Required Skills',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: event.requiredSkills.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                                );
                              }).toList(),
                            ),
                            
                            const Divider(height: 32),
                            
                            // Organizer
                            const Text(
                              'Organizer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                                                        Row(
                              children: [
                                if (event.organizerLogo != null)
                                  CircleAvatar(
                                    backgroundImage: AssetImage(event.organizerLogo!),
                                    radius: 24,
                                  ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.organizerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Trusted Organizer',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const Divider(height: 32),
                            
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: event.isFull
                                        ? null
                                        : () {
                                            // Handle participation logic
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: event.isFull
                                          ? Colors.grey
                                          : AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(
                                      event.isFull ? 'Event Full' : 'Join Event',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Handle sharing logic
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: Theme.of(context).dividerColor),
                                    ),
                                    child: const Text(
                                      'Share Event',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.environmental:
        return Icons.nature;
      case EventCategory.humanitarian:
        return Icons.volunteer_activism;
      case EventCategory.educational:
        return Icons.school;
      case EventCategory.animalWelfare:
        return Icons.pets;
      case EventCategory.communityService:
        return Icons.people;
      case EventCategory.healthcareSupport:
        return Icons.local_hospital;
      case EventCategory.disasterRelief:
        return Icons.warning;
      case EventCategory.artsAndCulture:
        return Icons.color_lens;
      case EventCategory.sportsAndRecreation:
        return Icons.sports;
      case EventCategory.technology:
        return Icons.computer;
    }
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.environmental:
        return Colors.green;
      case EventCategory.humanitarian:
        return AppTheme.primaryColor;
      case EventCategory.educational:
        return Colors.amber;
      case EventCategory.animalWelfare:
        return Colors.purple;
      case EventCategory.communityService:
        return Colors.orange;
      case EventCategory.healthcareSupport:
        return Colors.blue;
      case EventCategory.disasterRelief:
        return Colors.red;
      case EventCategory.artsAndCulture:
        return Colors.pink;
      case EventCategory.sportsAndRecreation:
        return Colors.teal;
      case EventCategory.technology:
        return Colors.indigo;
    }
  }
}
