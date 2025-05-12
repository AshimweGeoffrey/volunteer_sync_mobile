import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/event.dart';
import '../../theme/app_theme.dart';

class EventDetailBottomSheet extends StatefulWidget {
  final VolunteerEvent event;

  const EventDetailBottomSheet({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventDetailBottomSheet> createState() => _EventDetailBottomSheetState();
}

class _EventDetailBottomSheetState extends State<EventDetailBottomSheet> {
  bool _isExpanded = false;
  final double _collapsedHeight = 400;
  final double _expandedHeight = 600;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isExpanded ? _expandedHeight : _collapsedHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventInfo(context),
                  const Divider(height: 32),
                  _buildDescription(context),
                  const Divider(height: 32),
                  _buildRequirements(context),
                  const Divider(height: 32),
                  _buildLocationSection(context),
                  const Divider(height: 32),
                  _buildOrganizer(context),
                  const SizedBox(height: 32),
                  _buildAttendees(context),
                  const SizedBox(height: 80), // Space for button
                ],
              ),
            ),
          ),
          _buildRegisterButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Event image or category color background
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: _getCategoryColor(widget.event.category).withOpacity(0.2),
            image: widget.event.imageUrl != null
                ? DecorationImage(
                    image: AssetImage(widget.event.imageUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
        ),
        // Back handle
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        // Close button
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        // Category badge
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(widget.event.category),
                  size: 18,
                  color: _getCategoryColor(widget.event.category),
                ),
                const SizedBox(width: 6),
                Text(
                  _getCategoryName(widget.event.category),
                  style: TextStyle(
                    color: _getCategoryColor(widget.event.category),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Event title on bottom of the image
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Text(
              widget.event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Details',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Text(
              'Date: ${widget.event.formattedDate}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 8),
            Text(
              'Time: ${widget.event.formattedTime}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.people, size: 20),
            const SizedBox(width: 8),
            Text(
              'Spots: ${widget.event.spotsAvailable}/${widget.event.spotsTotal} available',
              style: TextStyle(
                fontSize: 16,
                color: widget.event.spotsAvailable > 0
                    ? Colors.green
                    : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.emoji_events, size: 20),
            const SizedBox(width: 8),
            Text(
              'Impact Points: ${widget.event.impactPoints}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        if (widget.event.isVirtual) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.computer, size: 20),
              const SizedBox(width: 8),
              Text(
                'Virtual Event',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.accentBlueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 12),
        Text(
          widget.event.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildRequirements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requirements',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.event.requiredSkills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: AppTheme.surfaceColor,
              side: BorderSide(
                color: AppTheme.dividerColor.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.event.location,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.event.coordinates,
                    zoom: 14,
                  ),
                  liteModeEnabled: true,
                  markers: {
                    Marker(
                      markerId: MarkerId(widget.event.id),
                      position: widget.event.coordinates,
                    ),
                  },
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'mapDirections',
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      // Open map directions
                    },
                    child: const Icon(Icons.directions),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.event.isVirtual) ...[
          const SizedBox(height: 8),
          Text(
            '${widget.event.distanceFromUser} miles from your location',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrganizer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Organizer',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: widget.event.organizerLogo != null
                      ? DecorationImage(
                          image: AssetImage(widget.event.organizerLogo!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.event.organizerLogo == null
                    ? Icon(
                        Icons.business,
                        color: Colors.grey.shade700,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.organizerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                      ),
                      onPressed: () {
                        // View organizer profile or other events
                      },
                      child: const Text('View profile'),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  // Follow organizer
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendees(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attendees',
              style: AppTheme.subheadingStyle,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'Show less' : 'Show more'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < min(5, widget.event.attendees.length); i++)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: AssetImage(
                    'assets/images/volunteer${i + 1}.jpg',
                  ),
                ),
              ),
            if (widget.event.attendees.length > 5)
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.surfaceColor,
                child: Text(
                  '+${widget.event.attendees.length - 5}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: widget.event.spotsAvailable > 0
              ? () {
                  // Register for event
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registration successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.event.spotsAvailable > 0
                ? AppTheme.primaryColor
                : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.event.spotsAvailable > 0
                ? 'Register Now'
                : 'Event Fully Booked',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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

  String _getCategoryName(EventCategory category) {
    final name = category.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }
}
