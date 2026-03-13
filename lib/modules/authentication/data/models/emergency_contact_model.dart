class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phoneNumber': phoneNumber, 'email': email};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
