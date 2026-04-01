import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/screens/chat_screen.dart';
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
      return const DriverBottomSheetShimmer();
    }

    if (!provider.hasActiveRide || ride == null) return const SizedBox.shrink();

    // 0. Ride Completed State
    if (provider.isRideCompleted) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64.sp),
            SizedBox(height: 16.h),
            const Text(
              'Ride Completed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            const Text(
              'You have successfully reached the destination.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => provider.resetRideState(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: const Text('Go Home', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    // 1. Arrived at Pickup State - Driver enters OTP to start ride
    if (provider.isArrivedAtPickup && !provider.isRideStarted) {
      return DriverSideAtPickupSheet(
        ride: ride,
        isLoading: provider.isLoading,
        onCall: () => _handleCall(ride.rideDetails?.riderPhoneNumber),
        onChat: () => _handleChat(context),
        onStartRide: (otp) => provider.startRide(otp),
      );
    }

    // 2. Trip in Progress State - Driver completes ride
    if (provider.isRideStarted) {
      return DriverSideInProgressSheet(
        ride: ride,
        isLoading: provider.isLoading,
        onCall: () => _handleCall(ride.rideDetails?.riderPhoneNumber),
        onChat: () => _handleChat(context),
        onCompleteRide: () => provider.completeRide(),
      );
    }

    // 3. On the Way to Pickup State - Driver notifies arrival
    return DriverSideOnWaySheet(
      ride: ride,
      isLoading: provider.isLoading,
      onCall: () => _handleCall(ride.rideDetails?.riderPhoneNumber),
      onChat: () => _handleChat(context),
      onArrived: () => provider.notifyArrival(),
    );
  }

  void _handleCall(String? phone) async {
    if (phone != null && phone.isNotEmpty) {
      final url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  void _handleChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen(isDriver: true)),
    );
  }
}
