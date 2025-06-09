class PsychologistModel {
  final String id;
  final String fullName;
  final String licenseNumber;
  bool available;
  final int? consultationFee;
  final String email;
  final List<String> specializations;
  final String description;
  final List<Education> education;
  final String? address;

  PsychologistModel({
    required this.id,
    required this.fullName,
    required this.licenseNumber,
    required this.available,
    required this.consultationFee,
    required this.email,
    required this.specializations,
    required this.description,
    required this.education,
    this.address,
  });

  factory PsychologistModel.fromJson(Map<String, dynamic> json) {
    List<Education> educationList = [];
    if (json['education'] != null) {
      educationList = List<Education>.from(
          json['education'].map((x) => Education.fromJson(x)));
    }
    return PsychologistModel(
      id: json['id'],
      fullName: json['full_name'],
      licenseNumber: json['license_number'],
      available: json['available'],
      consultationFee: json['consultation_fee'] as int?,
      email: json['email'],
      specializations: List<String>.from(json['specializations']),
      description: json['description'],
      education: educationList,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'license_number': licenseNumber,
      'available': available,
      'consultation_fee': consultationFee,
      'email': email,
      'specializations': specializations,
      'description': description,
      'education': education.map((e) => e.toJson()).toList(),
      'address': address,
    };
  }
}

class Education {
  final String degree;
  final String university;

  Education({
    required this.degree,
    required this.university,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree'],
      university: json['university'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'university': university,
    };
  }
}
