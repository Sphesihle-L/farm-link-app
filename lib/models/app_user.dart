enum UserRole {
  worker,
  farmer;

  String get dbValue => switch (this) {
        UserRole.worker => 'worker',
        UserRole.farmer => 'farmer',
      };

  String get roleLabel => switch (this) {
        UserRole.worker => "I'm looking for work",
        UserRole.farmer => 'I need workers',
      };
}

UserRole roleFromDb(String? v) => UserRole.values.firstWhere(
      (r) => r.dbValue == v,
      orElse: () => UserRole.worker,
    );

class AppUser {
  final String id;
  final String displayName;
  final UserRole role;
  final String area;
  final String phone;
  final String bio;
  final String farmName; // Farmer only
  final double rating;
  final DateTime createdAt;
  
  // New Worker Fields
  final List<String> skills;
  final String experience;
  final String previousWork;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.role,
    this.area = '',
    this.phone = '',
    this.bio = '',
    this.farmName = '',
    this.rating = 5.0,
    this.skills = const [], // Default to empty list
    this.experience = 'No experience',
    this.previousWork = '',
    required this.createdAt,
  });

  AppUser copyWith({
    String? displayName,
    String? area,
    String? phone,
    String? bio,
    String? farmName,
    List<String>? skills,
    String? experience,
    String? previousWork,
  }) =>
      AppUser(
        id: id,
        displayName: displayName ?? this.displayName,
        role: role,
        area: area ?? this.area,
        phone: phone ?? this.phone,
        bio: bio ?? this.bio,
        farmName: farmName ?? this.farmName,
        rating: rating,
        skills: skills ?? this.skills,
        experience: experience ?? this.experience,
        previousWork: previousWork ?? this.previousWork,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'role': role.dbValue,
        'area': area,
        'phone': phone,
        'bio': bio,
        'farmName': farmName,
        'rating': rating,
        'skills': skills,
        'experience': experience,
        'previousWork': previousWork,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory AppUser.fromMap(String id, Map<String, dynamic> m) => AppUser(
        id: id,
        displayName: m['displayName'] as String? ?? '',
        role: roleFromDb(m['role'] as String?),
        area: m['area'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        bio: m['bio'] as String? ?? '',
        farmName: m['farmName'] as String? ?? '',
        rating: (m['rating'] as num?)?.toDouble() ?? 5.0,
        skills: (m['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
        experience: m['experience'] as String? ?? 'No experience',
        previousWork: m['previousWork'] as String? ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}