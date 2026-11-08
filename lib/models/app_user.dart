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
  final String farmName;
  final double rating;
  final DateTime createdAt;

  // Worker Fields
  final List<String> skills;
  final String experience;
  final String previousWork;
  final List<String> availableDays;
  final String preferredTime;
  final bool shortNotice;
  final String preferredDistance;
  final bool hasTransport;
  final String additionalNotes;

  // Farmer Fields
  final String farmAddress;
  final String workerTravelDistance;
  final List<String> offeredWorkTypes;
  final String farmDescription; // <-- Added
  final String farmSize; // <-- Added

  const AppUser({
    required this.id,
    required this.displayName,
    required this.role,
    this.area = '',
    this.phone = '',
    this.bio = '',
    this.farmName = '',
    this.rating = 5.0,
    this.skills = const [],
    this.experience = 'No experience',
    this.previousWork = '',
    this.availableDays = const [],
    this.preferredTime = 'Morning',
    this.shortNotice = false,
    this.preferredDistance = 'Within 10 km',
    this.hasTransport = false,
    this.additionalNotes = '',
    this.farmAddress = '',
    this.workerTravelDistance = 'Within 10 km',
    this.offeredWorkTypes = const [],
    this.farmDescription = '', // <-- Added
    this.farmSize = '', // <-- Added
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
    List<String>? availableDays,
    String? preferredTime,
    bool? shortNotice,
    String? preferredDistance,
    bool? hasTransport,
    String? additionalNotes,
    String? farmAddress,
    String? workerTravelDistance,
    List<String>? offeredWorkTypes,
    String? farmDescription, // <-- Added
    String? farmSize, // <-- Added
  }) => AppUser(
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
    availableDays: availableDays ?? this.availableDays,
    preferredTime: preferredTime ?? this.preferredTime,
    shortNotice: shortNotice ?? this.shortNotice,
    preferredDistance: preferredDistance ?? this.preferredDistance,
    hasTransport: hasTransport ?? this.hasTransport,
    additionalNotes: additionalNotes ?? this.additionalNotes,
    farmAddress: farmAddress ?? this.farmAddress,
    workerTravelDistance: workerTravelDistance ?? this.workerTravelDistance,
    offeredWorkTypes: offeredWorkTypes ?? this.offeredWorkTypes,
    farmDescription: farmDescription ?? this.farmDescription, // <-- Added
    farmSize: farmSize ?? this.farmSize, // <-- Added
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
    'availableDays': availableDays,
    'preferredTime': preferredTime,
    'shortNotice': shortNotice,
    'preferredDistance': preferredDistance,
    'hasTransport': hasTransport,
    'additionalNotes': additionalNotes,
    'farmAddress': farmAddress,
    'workerTravelDistance': workerTravelDistance,
    'offeredWorkTypes': offeredWorkTypes,
    'farmDescription': farmDescription, // <-- Added
    'farmSize': farmSize, // <-- Added
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
    availableDays:
        (m['availableDays'] as List?)?.map((e) => e.toString()).toList() ?? [],
    preferredTime: m['preferredTime'] as String? ?? 'Morning',
    shortNotice: m['shortNotice'] as bool? ?? false,
    preferredDistance: m['preferredDistance'] as String? ?? 'Within 10 km',
    hasTransport: m['hasTransport'] as bool? ?? false,
    additionalNotes: m['additionalNotes'] as String? ?? '',
    farmAddress: m['farmAddress'] as String? ?? '',
    workerTravelDistance:
        m['workerTravelDistance'] as String? ?? 'Within 10 km',
    offeredWorkTypes:
        (m['offeredWorkTypes'] as List?)?.map((e) => e.toString()).toList() ??
        [],
    farmDescription: m['farmDescription'] as String? ?? '', // <-- Added
    farmSize: m['farmSize'] as String? ?? '', // <-- Added
    createdAt:
        DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
