import 'package:google_maps_flutter/google_maps_flutter.dart';

enum EventCategory {
  environmental,
  humanitarian,
  educational,
  animalWelfare,
  communityService,
  healthcareSupport,
  disasterRelief,
  artsAndCulture,
  sportsAndRecreation,
  technology
}

class VolunteerEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String? imageUrl;
  final LatLng coordinates;
  final int spotsAvailable;
  final int spotsTotal;
  final List<String> requiredSkills;
  final String organizerName;
  final String? organizerLogo;
  final EventCategory category;
  final double distanceFromUser; // in miles or km
  final bool isVirtual;
  final List<String> attendees;
  final int impactPoints;

  VolunteerEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.imageUrl,
    required this.coordinates,
    required this.spotsAvailable,
    required this.spotsTotal,
    required this.requiredSkills,
    required this.organizerName,
    this.organizerLogo,
    required this.category,
    required this.distanceFromUser,
    required this.isVirtual,
    required this.attendees,
    required this.impactPoints,
  });

  bool get isFull => spotsAvailable == 0;
  
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);
    
    if (eventDate.compareTo(today) == 0) {
      return 'Today';
    } else if (eventDate.compareTo(tomorrow) == 0) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
  
  String get formattedTime {
    String formatTimeOfDay(TimeOfDay timeOfDay) {
      final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
      final minute = timeOfDay.minute.toString().padLeft(2, '0');
      final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }
    
    return '${formatTimeOfDay(startTime)} - ${formatTimeOfDay(endTime)}';
  }
}
