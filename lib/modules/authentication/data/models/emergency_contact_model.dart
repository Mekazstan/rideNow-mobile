class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final bool isAppUser;
  final String? profilePhoto;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.isAppUser = false,
    this.profilePhoto,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      isAppUser: json['isAppUser'] as bool? ?? false,
      profilePhoto: json['profilePhoto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'isAppUser': isAppUser,
      'profilePhoto': profilePhoto,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
