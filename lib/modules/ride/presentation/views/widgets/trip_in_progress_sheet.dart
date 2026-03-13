// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/safety_menu_overlay.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/share_ride_dialog.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';
import 'package:ridenowappsss/core/services/sharing_service.dart';

class TripInProgressSheet extends StatelessWidget {
  final RideDetails? rideDetails;
  final String? pickupAddress;
  final String? destinationAddress;

  // Computed properties for sharing
  String get _rideId => rideDetails?.id ?? '';
  // This base URL should ideally come from a configuration or environment variable.
  // For this example, a placeholder is used.
  static const String _baseWebUrl = 'https://ridenow.app/ride';
  String get deepLink => 'ridenow://watch/$_rideId';
  String get webFallback => '$_baseWebUrl/$_rideId';

  // The deepLink is used by the OS to open the app directly.
  // The webFallback is used to redirect to stores if the app is not installed.
  String get message =>
      "Watch my ride on RideNow: $webFallback\n\nApp Link: $deepLink";

  final String? vehicleInfo;
  final String? driverNameOverride;
  final double? driverRatingOverride;
  final String? driverPhotoOverride;
  final String? carModel;
  final String? plateNumber;
  final VoidCallback onCancel;
  final VoidCallback? onSimulate;
  final VoidCallback? onStopSimulation;
  final bool isSimulating;

  const TripInProgressSheet({
    super.key,
    required this.rideDetails,
    this.pickupAddress,
    this.destinationAddress,
    this.vehicleInfo,
    this.driverNameOverride,
    this.driverRatingOverride,
    this.driverPhotoOverride,
    this.carModel,
    this.plateNumber,
    required this.onCancel,
    this.onSimulate,
    this.onStopSimulation,
    this.isSimulating = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final driver = rideDetails?.driver;
    final driverName = driverNameOverride ?? driver?.name ?? 'Driver';
    final rating = driverRatingOverride ?? driver?.rating ?? 4.9;
    final photoUrl = driverPhotoOverride ?? driver?.profileImage;
    final dest =
        destinationAddress ??
        rideDetails?.destination?.address ??
        'Destination';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(appColors),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '16:40PM, Monday | 23 mins',
                  style: appFonts.textSmRegular.copyWith(
                    color: appColors.textSecondary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "You're on your way to $dest",
                  style: appFonts.textBaseMedium.copyWith(
                    color: appColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20.h),

                // Driver Info & Actions
                Row(
                  children: [
                    _buildDriverAvatar(photoUrl, appColors),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver',
                            style: appFonts.textSmRegular.copyWith(
                              color: appColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  driverName,
                                  style: appFonts.textSmMedium.copyWith(
                                    color: appColors.textPrimary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildRatingBadge(rating, appColors),
                            ],
                          ),
                          Text(
                            carModel != null && carModel!.isNotEmpty
                                ? carModel!
                                : 'Nissan 16v 322 Machine',
                            style: appFonts.textSmRegular.copyWith(
                              color: appColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildActionIcons(context, appColors),
                  ],
                ),

                SizedBox(height: 24.h),

                // Ride Details Section
                _buildRideDetails(appColors, appFonts),

                SizedBox(height: 20.h),

                // Action Buttons
                _buildActionButtons(context, appColors, appFonts),

                SizedBox(height: 20.h),

                // Safety Section
                _buildSafetySection(appColors, appFonts),

                // Simulation controls
                if (onSimulate != null) ...[
                  SizedBox(height: 20.h),
                  _buildSimulationControls(appColors, appFonts),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle(AppColorExtension appColors) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildDriverAvatar(String? imageUrl, AppColorExtension appColors) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child:
            imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : Icon(Icons.person, color: Colors.white, size: 28.sp),
      ),
    );
  }

  Widget _buildRatingBadge(double rating, AppColorExtension appColors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star, size: 8.sp, color: Colors.white),
        ),
        SizedBox(width: 4.w),
        Text(
          rating.toInt().toString(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons(BuildContext context, AppColorExtension appColors) {
    return Row(
      children: [
        _buildIconCircle(Icons.location_on, appColors.blue600, Colors.white),
        SizedBox(width: 8.w),
        _buildIconCircle(
          Icons.security,
          appColors.blue600,
          Colors.white,
          onTap: () => _showSafetyMenu(context),
        ),
        SizedBox(width: 8.w),
        _buildIconCircle(
          Icons.close,
          const Color(0xFFFEE2E2),
          const Color(0xFFEF4444),
          onTap: onCancel,
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
        ),
      ],
    );
  }

  void _showSafetyMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      items: [
        PopupMenuItem(
          enabled: false,
          child: SafetyMenuOverlay(
            onShareLiveLocation: () {
              Navigator.pop(context); // Close menu
              _showShareDialog(context); // Use sheet context for dialog
            },
            onCallPolice: () {
              Navigator.pop(context);
              // Handle Call Police
            },
          ),
        ),
      ],
    );
  }

  void _showShareDialog(BuildContext context) {
    // Capture provider before opening dialog to ensure we have a stable reference
    final provider = context.read<RideProvider>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => ShareRideDialog(
            onFacebook: () => _shareRide(dialogContext, provider, 'Facebook'),
            onSnapchat: () => _shareRide(dialogContext, provider, 'Snapchat'),
            onWhatsapp: () => _shareRide(dialogContext, provider, 'WhatsApp'),
          ),
    );
  }

  Future<void> _shareRide(
    BuildContext context,
    RideProvider provider,
    String platform,
  ) async {
    final rideId = rideDetails?.id ?? provider.currentRideId ?? 'test-ride-id';

    // We use getIt directly to avoid ancestor lookup if the sheet unmounts
    await getIt<SharingService>().shareRide(
      rideId,
      platform: platform.toLowerCase(),
    );
  }

  Widget _buildIconCircle(
    IconData icon,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
    BoxBorder? border,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Icon(icon, color: iconColor, size: 20.sp),
      ),
    );
  }

  Widget _buildRideDetails(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: appColors.blue600, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Your ride details',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.only(left: 12.w),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: appColors.blue600.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildDetailItem(
                'Going to',
                destinationAddress ??
                    rideDetails?.destination?.address ??
                    '...',
                appColors,
                appFonts,
              ),
              SizedBox(height: 16.h),
              _buildDetailItem(
                'From',
                pickupAddress ?? rideDetails?.pickupLocation?.address ?? '...',
                appColors,
                appFonts,
              ),
              SizedBox(height: 16.h),
              _buildDetailItem(
                'Vehicle',
                vehicleInfo ?? rideDetails?.vehicleType ?? '...',
                appColors,
                appFonts,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: appFonts.textSmRegular.copyWith(
              color: appColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetySection(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: appColors.blue50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: appColors.blue600,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            'Safety',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down, color: appColors.gray400),
        ],
      ),
    );
  }

  Widget _buildSimulationControls(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSimulating ? onStopSimulation : onSimulate,
        icon: Icon(isSimulating ? Icons.stop : Icons.play_arrow),
        label: Text(
          isSimulating ? 'Stop Simulation' : 'Simulate Ride Movement',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSimulating ? Colors.orange : appColors.blue600,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleShareLiveLocation(context),
            icon: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 20.sp,
            ),
            label: Text(
              'Share live location',
              style: appFonts.textBaseMedium.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.blue600,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle Call Police
            },
            icon: Icon(Icons.shield_outlined, color: Colors.white, size: 20.sp),
            label: Text(
              'Call Police',
              style: appFonts.textBaseMedium.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.blue600,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  void _handleShareLiveLocation(BuildContext context) {
    // Show share options directly
    _showShareDialog(context);
  }
}
