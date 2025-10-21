class ConsultationModel {
  final String id;
  final String userId;
  final String specialistId;
  final String specialistName;
  final String specialistTitle;
  final String specialistImage;
  final String specialization;
  final String specialistSpecialization;
  final DateTime scheduledDate;
  final Duration duration;
  final ConsultationStatus status;
  final ConsultationType type;
  final double price;
  final String? meetingLink;
  final String? notes;
  final String? sessionNotes;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? rating;
  final String? feedback;

  ConsultationModel({
    required this.id,
    required this.userId,
    required this.specialistId,
    required this.specialistName,
    required this.specialistTitle,
    required this.specialistImage,
    required this.specialization,
    required this.specialistSpecialization,
    required this.scheduledDate,
    required this.duration,
    required this.status,
    required this.type,
    required this.price,
    this.meetingLink,
    this.notes,
    this.sessionNotes,
    this.attachments,
    required this.createdAt,
    this.completedAt,
    this.rating,
    this.feedback,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id'],
      userId: json['userId'],
      specialistId: json['specialistId'],
      specialistName: json['specialistName'],
      specialistTitle: json['specialistTitle'],
      specialistImage: json['specialistImage'],
      specialization: json['specialization'],
      specialistSpecialization: json['specialistSpecialization'] ?? json['specialization'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      duration: Duration(minutes: json['duration']),
      status: ConsultationStatus.values.firstWhere(
        (e) => e.toString() == 'ConsultationStatus.${json['status']}',
      ),
      type: ConsultationType.values.firstWhere(
        (e) => e.toString() == 'ConsultationType.${json['type']}',
      ),
      price: json['price'].toDouble(),
      meetingLink: json['meetingLink'],
      notes: json['notes'],
      sessionNotes: json['sessionNotes'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      rating: json['rating'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'specialistId': specialistId,
      'specialistName': specialistName,
      'specialistTitle': specialistTitle,
      'specialistImage': specialistImage,
      'specialization': specialization,
      'specialistSpecialization': specialistSpecialization,
      'scheduledDate': scheduledDate.toIso8601String(),
      'duration': duration.inMinutes,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'price': price,
      'meetingLink': meetingLink,
      'notes': notes,
      'sessionNotes': sessionNotes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
    };
  }
}

enum ConsultationStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

enum ConsultationType {
  video,
  audio,
  chat,
  inPerson,
}

class SpecialistModel {
  final String id;
  final String name;
  final String title;
  final String image;
  final String specialization;
  final String description;
  final List<String> qualifications;
  final int experienceYears;
  final double rating;
  final int reviewsCount;
  final double pricePerSession;
  final List<String> languages;
  final List<String> subSpecializations;
  final List<ConsultationType> supportedTypes;
  final bool isAvailable;
  final String? nextAvailableSlot;
  final List<String> workingHours;

  SpecialistModel({
    required this.id,
    required this.name,
    required this.title,
    required this.image,
    required this.specialization,
    required this.description,
    required this.qualifications,
    required this.experienceYears,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerSession,
    required this.languages,
    required this.subSpecializations,
    required this.supportedTypes,
    required this.isAvailable,
    this.nextAvailableSlot,
    required this.workingHours,
  });

  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    return SpecialistModel(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      image: json['image'],
      specialization: json['specialization'],
      description: json['description'],
      qualifications: List<String>.from(json['qualifications']),
      experienceYears: json['experienceYears'],
      rating: json['rating'].toDouble(),
      reviewsCount: json['reviewsCount'],
      pricePerSession: json['pricePerSession'].toDouble(),
      languages: List<String>.from(json['languages'] ?? json['availableLanguages'] ?? []),
      subSpecializations: List<String>.from(json['subSpecializations'] ?? []),
      supportedTypes: (json['supportedTypes'] as List)
          .map((e) => ConsultationType.values.firstWhere(
                (type) => type.toString() == 'ConsultationType.$e',
              ))
          .toList(),
      isAvailable: json['isAvailable'],
      nextAvailableSlot: json['nextAvailableSlot'],
      workingHours: List<String>.from(json['workingHours'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'image': image,
      'specialization': specialization,
      'description': description,
      'qualifications': qualifications,
      'experienceYears': experienceYears,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'pricePerSession': pricePerSession,
      'languages': languages,
      'subSpecializations': subSpecializations,
      'supportedTypes': supportedTypes.map((e) => e.toString().split('.').last).toList(),
      'isAvailable': isAvailable,
      'nextAvailableSlot': nextAvailableSlot,
      'workingHours': workingHours,
    };
  }
}