import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/community/presentation/providers/community_provider.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';

class LiveRideTrackingScreen extends StatefulWidget {
  final String shareToken;
  final String? userName; // For header "You're watching X's ride"

  const LiveRideTrackingScreen({
    super.key,
    required this.shareToken,
    this.userName,
  });

  @override
  State<LiveRideTrackingScreen> createState() => _LiveRideTrackingScreenState();
}

class _LiveRideTrackingScreenState extends State<LiveRideTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRideDetails();
    });
  }

  Future<void> _loadRideDetails() async {
    final success = await context.read<CommunityProvider>().fetchLiveRide(
      shareToken: widget.shareToken,
    );
    if (!success && mounted) {
      final error = context.read<CommunityProvider>().errorMessage;
      AppErrorDialog.show(
        context,
        title: 'Error',
        message: error ?? 'Failed to load ride details',
        buttonText: 'Retry',
        onConfirm: _loadRideDetails,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: Consumer<CommunityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.liveRideDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final ride = provider.liveRideDetails;
          if (ride == null) {
            return const Center(child: Text('Ride not found'));
          }

          final watchingName = widget.userName ?? ride.riderName;

          return Stack(
            children: [
              // Map View
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    ride.currentLocation.lat,
                    ride.currentLocation.lng,
                  ),
                  zoom: 15,
                ),

                markers: {
                  Marker(
                    markerId: const MarkerId('driver'),
                    position: LatLng(
                      ride.currentLocation.lat,
                      ride.currentLocation.lng,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: LatLng(
                      ride.destination.coordinates.lat,
                      ride.destination.coordinates.lng,
                    ),
                  ),
                },
              ),

              // Custom Header Banner
              Positioned(
                top: 60.h,
                left: 20.w,
                right: 20.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundImage: const NetworkImage(
                          'https://via.placeholder.com/150',
                        ), // Placeholder for watcher/user image
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "You're watching ${watchingName}'s ride",
                          style: appFonts.textSmMedium.copyWith(
                            color: Colors.pink,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Sheet
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Going to ${ride.destination.address}',
                        style: appFonts.textBaseMedium.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Driver Info
                      Row(
                        children: [
                          Container(
                            width: 50.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              image: DecorationImage(
                                image: NetworkImage(ride.driver.photo),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver',
                                  style: appFonts.textSmRegular.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      ride.driver.name,
                                      style: appFonts.textBaseMedium.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: appColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 10.sp,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      ride.driver.rating.toString(),
                                      style: appFonts.textSmMedium.copyWith(
                                        color: appColors.textPrimary,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${ride.driver.vehicle} ${ride.driver.vehicleType}',
                                  style: appFonts.textSmRegular.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Ride Route Detail Visualization
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: appColors.blue600,
                                size: 24.sp,
                              ),
                              Container(
                                width: 2,
                                height: 40.h,
                                color: appColors.blue600.withOpacity(0.3),
                              ),
                            ],
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ride details',
                                  style: appFonts.textBaseMedium.copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: appColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                _buildRouteItem(
                                  context,
                                  'Going to',
                                  ride.destination.address,
                                  appFonts,
                                  appColors,
                                ),
                                SizedBox(height: 16.h),
                                _buildRouteItem(
                                  context,
                                  'From',
                                  ride.pickupLocation.address,
                                  appFonts,
                                  appColors,
                                ),
                                SizedBox(height: 16.h),
                                _buildRouteItem(
                                  context,
                                  'Vehicle',
                                  ride.driver.vehicle ?? 'Car',
                                  appFonts,
                                  appColors,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRouteItem(
    BuildContext context,
    String label,
    String value,
    AppFontThemeExtension appFonts,
    AppColorExtension appColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appFonts.textSmRegular.copyWith(
            color: Colors.grey[500],
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: appFonts.textBaseMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
