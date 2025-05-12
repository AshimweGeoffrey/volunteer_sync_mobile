// Update the constructor to ensure it accepts all the required parameters
class VolunteerEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final double latitude;
  final double longitude;
  final String organizerName;
  final String organizerLogo;
  final int availableSpots;
  final int registeredVolunteers;
  final EventCategory category;
  final List<String> skills;
  final String imageUrl;

  VolunteerEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.organizerName,
    required this.organizerLogo,
    required this.availableSpots,
    required this.registeredVolunteers,
    required this.category,
    this.skills = const [],
    this.imageUrl = '',
  });

  // Rest of the class methods...
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
