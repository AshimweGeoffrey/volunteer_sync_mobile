import 'package:flutter/material.dart';
import 'package:volunteer_sync/data/models/event_category.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final bool isVirtual;
  final List<String> attendees;
  final int impactPoints;

  // Computed properties
  LatLng get coordinates => LatLng(latitude, longitude);
  int get spotsAvailable => availableSpots - registeredVolunteers;
  int get spotsTotal => availableSpots;
  String get formattedDate => "${date.day}/${date.month}/${date.year}";
  String get formattedTime => "${formatTimeOfDay(startTime)} - ${formatTimeOfDay(endTime)}";
  double get distanceFromUser => 2.5; // Mock value, replace with actual distance calculation

  // Getters for necessary UI elements
  List<String> get requiredSkills => skills;

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
    this.isVirtual = false,
    this.attendees = const [],
    this.impactPoints = 0,
  });

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
