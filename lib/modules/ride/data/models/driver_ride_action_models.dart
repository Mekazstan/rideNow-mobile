import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';

/// Request model for accepting a ride request
class DriverAcceptRideRequest {
  final LocationModelDriver driverLocation;
  final int estimatedArrival;

  DriverAcceptRideRequest({
    required this.driverLocation,
    required this.estimatedArrival,
  });

  Map<String, dynamic> toJson() {
    return {
      'driver_location': {
        'lat': driverLocation.coordinates.lat,
        'lng': driverLocation.coordinates.lng,
        'address': driverLocation.address,
      },
      'estimated_arrival': estimatedArrival,
    };
  }
}

/// Request model for declining a ride request
class DeclineRideRequest {
  final String reason;
  final String? customReason;

  DeclineRideRequest({required this.reason, this.customReason});

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      if (customReason != null) 'custom_reason': customReason,
    };
  }
}

/// Request model for notifying arrival
class ArrivalRequest {
  final String arrivalType; // e.g., "pickup" or "destination"
  final LocationModelDriver location;
  final String arrivalTime;

  ArrivalRequest({
    required this.arrivalType,
    required this.location,
    required this.arrivalTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'arrival_type': arrivalType,
      'location': {
        'lat': location.coordinates.lat,
        'lng': location.coordinates.lng,
        'address': location.address,
      },
      'arrival_time': arrivalTime,
    };
  }
}

/// Request model for cancelling a ride (from driver)
class DriverCancelRideRequest {
  final String reason;
  final String? description;
  final LocationModelDriver currentLocation;

  DriverCancelRideRequest({
    required this.reason,
    this.description,
    required this.currentLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'description': description ?? "",
      'current_location': {
        'lat': currentLocation.coordinates.lat,
        'lng': currentLocation.coordinates.lng,
        'address': currentLocation.address,
      },
    };
  }
}

/// Request model for completing a ride
class CompleteRideRequest {
  final String dropoffTime;
  final int odometerReading;
  final double actualDistance;

  CompleteRideRequest({
    required this.dropoffTime,
    required this.odometerReading,
    required this.actualDistance,
  });

  Map<String, dynamic> toJson() {
    return {
      'dropoffTime': dropoffTime,
      'odometerReading': odometerReading,
      'actualDistance': actualDistance,
    };
  }
}

/// Request model for updating driver location during ride
class DriverUpdateLocationRequest {
  final LocationUpdateModel location;
  final double heading;
  final double speed;
  final String timestamp;

  DriverUpdateLocationRequest({
    required this.location,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp,
    };
  }
}

class LocationUpdateModel {
  final double lat;
  final double lng;
  final String address;
  final double heading;
  final double speed;
  final String timestamp;

  LocationUpdateModel({
    required this.lat,
    required this.lng,
    required this.address,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp,
    };
  }
}

/// Request model for starting a ride
class StartRideRequest {
  final String rideCode;
  final LocationModelDriver driverLocation;
  final int odometerReading;

  StartRideRequest({
    required this.rideCode,
    required this.driverLocation,
    required this.odometerReading,
  });

  Map<String, dynamic> toJson() {
    return {
      'ride_code': rideCode,
      'driver_location': {
        'lat': driverLocation.coordinates.lat,
        'lng': driverLocation.coordinates.lng,
        'address': driverLocation.address,
      },
      'odometer_reading': odometerReading,
    };
  }
}

/// Response model for wallet earnings
class WalletEarningsResponse {
  final double availableBalance;
  final double pendingEarnings;
  final List<TransactionModel> transactions;

  WalletEarningsResponse({
    required this.availableBalance,
    required this.pendingEarnings,
    required this.transactions,
  });

  factory WalletEarningsResponse.fromJson(Map<String, dynamic> json) {
    return WalletEarningsResponse(
      availableBalance: (json['available_balance'] as num? ?? 0).toDouble(),
      pendingEarnings: (json['pending_earnings'] as num? ?? 0).toDouble(),
      transactions:
          (json['transactions'] as List? ?? [])
              .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class TransactionModel {
  final String id;
  final double amount;
  final String type;
  final String status;
  final String date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }
}
