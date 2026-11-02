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
  final String skills;
  final String farmName;
  final String bio;     // NEW
  final double rating;  // NEW
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.role,
    this.area = '',
    this.phone = '',
    this.skills = '',
    this.farmName = '',
    this.bio = '',
    this.rating = 5.0,
    required this.createdAt,
  });

  AppUser copyWith({
    String? displayName,
    String? area,
    String? phone,
    String? skills,
    String? farmName,
    String? bio,
  }) =>
      AppUser(
        id: id,
        displayName: displayName ?? this.displayName,
        role: role,
        area: area ?? this.area,
        phone: phone ?? this.phone,
        skills: skills ?? this.skills,
        farmName: farmName ?? this.farmName,
        bio: bio ?? this.bio,
        rating: rating,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'role': role.dbValue,
        'area': area,
        'phone': phone,
        'skills': skills,
        'farmName': farmName,
        'bio': bio,
        'rating': rating,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory AppUser.fromMap(String id, Map<String, dynamic> m) => AppUser(
        id: id,
        displayName: m['displayName'] as String? ?? '',
        role: roleFromDb(m['role'] as String?),
        area: m['area'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        skills: m['skills'] as String? ?? '',
        farmName: m['farmName'] as String? ?? '',
        bio: m['bio'] as String? ?? '',
        rating: (m['rating'] as num?)?.toDouble() ?? 5.0,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}