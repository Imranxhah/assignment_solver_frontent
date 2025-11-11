class Profile {
  String fullName;
  String universityName;
  String registrationNumber;
  String departmentName;

  Profile({
    required this.fullName,
    required this.universityName,
    required this.registrationNumber,
    required this.departmentName,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      fullName: json['full_name'] ?? '',
      universityName: json['university_name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      departmentName: json['department_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'university_name': universityName,
      'registration_number': registrationNumber,
      'department_name': departmentName,
    };
  }
}
