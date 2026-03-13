import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_side_on_way_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_side_at_pickup_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_side_in_progress_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_screenshimmer.dart';

class ActiveRideBottomSheet extends StatelessWidget {
  const ActiveRideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverProvider>();
    final ride = provider.activeRide;

    if (provider.isLoading) {
      return const DriverTripStateShimmer();
    }

    if (ride == null) return const SizedBox.shrink();

    // 1. Arrived at Pickup State - Driver enters OTP to start ride
    if (provider.isArrivedAtPickup && !provider.isRideStarted) {
      return DriverSideAtPickupSheet(
        ride: ride,
        isLoading: provider.isLoading,
        onCall: () {}, // Implementation later
        onChat: () {}, // Implementation later
        onStartRide: (otp) => provider.startRide(context, ride.rideId, otp),
      );
    }

    // 2. Trip in Progress State - Driver completes ride
    if (provider.isRideStarted) {
      return DriverSideInProgressSheet(
        ride: ride,
        isLoading: provider.isLoading,
        onCall: () {}, // Implementation later
        onChat: () {}, // Implementation later
        onCompleteRide: () => provider.completeRide(context, ride.rideId),
      );
    }

    // 3. On the Way to Pickup State - Driver notifies arrival
    return DriverSideOnWaySheet(
      ride: ride,
      isLoading: provider.isLoading,
      onCall: () {}, // Implementation later
      onChat: () {}, // Implementation later
      onArrived: () => provider.notifyArrival(context, ride.rideId, 'pickup'),
    );
  }
}
