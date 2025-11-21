import 'profile_model.dart';

class User {
  final int id;
  final String email;
  final String? username; // Made optional
  final bool isEmailVerified;
  final bool profileCompleted;
  final Profile? profile;

  User({
    required this.id,
    required this.email,
    this.username, // Made optional
    required this.isEmailVerified,
    required this.profileCompleted,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'], // Keep this for now, it might be returned from backend
      isEmailVerified: json['is_email_verified'] ?? false,
      profileCompleted: json['profile_completed'] ?? false,
      profile:
          json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_email_verified': isEmailVerified,
      'profile_completed': profileCompleted,
      'profile': profile?.toJson(),
    };
  }
}
