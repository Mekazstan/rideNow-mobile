// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_ride_request.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/otp_input_widget.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class DriverSideAtPickupSheet extends StatefulWidget {
  final AcceptRideResponse ride;
  final Function(String) onStartRide;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final bool isLoading;

  const DriverSideAtPickupSheet({
    super.key,
    required this.ride,
    required this.onStartRide,
    required this.onCall,
    required this.onChat,
    this.isLoading = false,
  });

  @override
  State<DriverSideAtPickupSheet> createState() =>
      _DriverSideAtPickupSheetState();
}

class _DriverSideAtPickupSheetState extends State<DriverSideAtPickupSheet> {
  late List<TextEditingController> _otpControllers;
  String _enteredOtp = '';

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

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
                Row(
                  children: [
                    _buildAvatar(widget.ride.rideDetails?.riderImage, appColors),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rider at Pickup',
                            style: appFonts.textSmRegular.copyWith(
                              color: appColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.ride.rideDetails?.riderName ?? 'Rider',
                                  style: appFonts.textSmMedium.copyWith(
                                    color: appColors.textPrimary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildRatingBadge(4.9, appColors),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildActionIcons(appColors),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  'Enter Ride Code',
                  style: appFonts.textBaseMedium.copyWith(
                    color: appColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Ask the rider for the 4-digit security code to start the ride.',
                  style: appFonts.textSmRegular.copyWith(
                    color: appColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                OtpInputWidget(
                  length: 4,
                  controllers: _otpControllers,
                  onCompleted: (otp) {
                    setState(() {
                      _enteredOtp = otp;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                RideNowButton(
                  title: 'Start Ride',
                  onTap:
                      _enteredOtp.length == 4
                          ? () => widget.onStartRide(_enteredOtp)
                          : null,
                  isLoading: widget.isLoading,
                  width: double.infinity,
                  height: 56.h,
                  colorSet: RideNowButtonColorSet.primary,
                ),
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

  Widget _buildAvatar(String? imageUrl, AppColorExtension appColors) {
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
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, color: Colors.white, size: 28.sp);
                    },
                  )
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
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons(AppColorExtension appColors) {
    return Row(
      children: [
        _buildIconCircle(
          Icons.call_outlined,
          const Color(0xFFEFF4FF),
          appColors.blue600,
          onTap: widget.onCall,
        ),
        SizedBox(width: 8.w),
        _buildIconCircle(
          Icons.chat_bubble_outline,
          const Color(0xFFEFF4FF),
          appColors.blue600,
          onTap: widget.onChat,
        ),
      ],
    );
  }

  Widget _buildIconCircle(
    IconData icon,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20.sp),
      ),
    );
  }
}
