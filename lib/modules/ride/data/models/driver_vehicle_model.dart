class Vehicle {
  final String id;
  final String type;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final bool isActive;
  final String verificationStatus;

  Vehicle({
    required this.id,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.isActive,
    required this.verificationStatus,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? json['vehicleType'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      color: json['color'] as String? ?? '',
      licensePlate: json['license_plate'] as String? ?? json['licensePlate'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? json['verificationStatus'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'is_active': isActive,
      'verification_status': verificationStatus,
    };
  }
}

class VehiclesResponse {
  final List<Vehicle> vehicles;

  VehiclesResponse({required this.vehicles});

  factory VehiclesResponse.fromJson(Map<String, dynamic> json) {
    return VehiclesResponse(
      vehicles: (json['vehicles'] as List<dynamic>?)
              ?.map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
