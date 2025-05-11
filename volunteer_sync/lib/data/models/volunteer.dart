class Volunteer {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String location;
  final int hoursCompleted;
  final int eventsAttended;
  final int pointsEarned;
  final List<String> skills;
  final List<String> interests;
  final String? bio;
  final DateTime joinedDate;
  final double latitude;
  final double longitude;

  Volunteer({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.location,
    required this.hoursCompleted,
    required this.eventsAttended,
    required this.pointsEarned,
    required this.skills,
    required this.interests,
    this.bio,
    required this.joinedDate,
    required this.latitude,
    required this.longitude,
  });
}
