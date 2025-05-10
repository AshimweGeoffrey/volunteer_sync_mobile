class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final int points;
  final int eventsAttended;
  final int hoursCompleted;

  UserModel({
    required this.id,
    required this.name, 
    required this.email,
    required this.role,
    this.photoUrl,
    this.points = 0,
    this.eventsAttended = 0,
    this.hoursCompleted = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      photoUrl: json['photo_url'],
      points: json['points'] ?? 0,
      eventsAttended: json['events_attended'] ?? 0,
      hoursCompleted: json['hours_completed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photo_url': photoUrl,
      'points': points,
      'events_attended': eventsAttended,
      'hours_completed': hoursCompleted,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? photoUrl,
    int? points,
    int? eventsAttended,
    int? hoursCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      eventsAttended: eventsAttended ?? this.eventsAttended,
      hoursCompleted: hoursCompleted ?? this.hoursCompleted,
    );
  }
}
