enum VehicleType { standard, luxury, bike, tricylce, seaterbus }

extension VehicleTypeExtension on VehicleType {
  String toApiValue() {
    switch (this) {
      case VehicleType.standard:
        return 'standard_ride';
      case VehicleType.luxury:
        return 'luxury_vehicle';
      case VehicleType.bike:
        return 'bike';
      case VehicleType.tricylce:
        return 'tricycle';
      case VehicleType.seaterbus:
        return 'seater_bus';
    }
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case VehicleType.standard:
        return 'Standard Ride';
      case VehicleType.luxury:
        return 'Luxury Vehicle';
      case VehicleType.bike:
        return 'Bikes';
      case VehicleType.tricylce:
        return 'Tricycle';
      case VehicleType.seaterbus:
        return 'Seater Bus';
    }
  }
}

VehicleType? vehicleTypeFromApiValue(String value) {
  switch (value) {
    case 'standard_ride':
      return VehicleType.standard;
    case 'luxury_vehicle':
      return VehicleType.luxury;
    case 'bike':
      return VehicleType.bike;
    case 'tricycle':
      return VehicleType.tricylce;
    case 'seater_bus':
      return VehicleType.seaterbus;
    default:
      return null;
  }
}
