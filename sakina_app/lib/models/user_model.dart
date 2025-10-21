class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isPremium;
  final Map<String, dynamic>? profile;
  final List<String>? interests;
  final String? languagePreference;
  final String? notificationSettings;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profilePicture,
    required this.createdAt,
    this.lastLogin,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isPremium = false,
    this.profile,
    this.interests,
    this.languagePreference = 'ar',
    this.notificationSettings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isPremium: json['isPremium'] ?? false,
      profile: json['profile'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      languagePreference: json['languagePreference'] ?? 'ar',
      notificationSettings: json['notificationSettings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isPremium': isPremium,
      'profile': profile,
      'interests': interests,
      'languagePreference': languagePreference,
      'notificationSettings': notificationSettings,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isPremium,
    Map<String, dynamic>? profile,
    List<String>? interests,
    String? languagePreference,
    String? notificationSettings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isPremium: isPremium ?? this.isPremium,
      profile: profile ?? this.profile,
      interests: interests ?? this.interests,
      languagePreference: languagePreference ?? this.languagePreference,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}
