// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/drivers_offers_bottom_sheet.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class RideConfirmationSheet {
  static void show(
    BuildContext context, {
    required String rideAmount,
    required String destination,
    required String pickup,
    required Function() onTopUp,
  }) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isDismissible: true,
      builder:
          (context) => _RideConfirmationContent(
            appColors: appColors,
            appFonts: appFonts,
            rideAmount: rideAmount,
            destination: destination,
            pickup: pickup,
            onTopUp: onTopUp,
          ),
    );
  }
}

class _RideConfirmationContent extends StatefulWidget {
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final String rideAmount;
  final String destination;
  final String pickup;
  final Function() onTopUp;

  const _RideConfirmationContent({
    required this.appColors,
    required this.appFonts,
    required this.rideAmount,
    required this.destination,
    required this.pickup,
    required this.onTopUp,
  });

  @override
  State<_RideConfirmationContent> createState() =>
      _RideConfirmationContentState();
}

class _RideConfirmationContentState extends State<_RideConfirmationContent> {
  bool _isBookingRide = false;

  Future<void> _handleBookRide(BuildContext context) async {
    final rideViewModel = context.read<RideProvider>();
    final fareAmount = double.tryParse(widget.rideAmount) ?? 0.0;

    if (fareAmount <= 0) {
      _showErrorSnackBar(context, 'Invalid fare amount');
      return;
    }

    setState(() {
      _isBookingRide = true;
    });

    try {
      // Call the API to create the ride
      final response = await rideViewModel.createRide(
        fareAmount: fareAmount,
        paymentMethod: RideConstants.paymentWallet,
      );

      if (!context.mounted) return;

      debugPrint('âœ… Ride created successfully');
      debugPrint('   Ride ID: ${response.rideId}');
      debugPrint('   Status: ${response.status}');

      setState(() {
        _isBookingRide = false;
      });

      final navigator = Navigator.of(context);
      navigator.pop();

      _showDriverOffersBottomSheet(
        navigator.context,
        rideViewModel,
        fareAmount,
      );
    } catch (e) {
      if (!context.mounted) return;

      setState(() {
        _isBookingRide = false;
      });

      // Show error message
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showErrorSnackBar(context, errorMessage);

      debugPrint('âŒ Error booking ride: $e');
    }
  }

  void _showDriverOffersBottomSheet(
    BuildContext context,
    RideProvider rideViewModel,
    double fareAmount,
  ) {
    // Show the bottom sheet with loading state
    DriverOffersBottomSheet.show(
      context,
      rideViewModel: rideViewModel,
      onBookDriver: (driver) async {
        debugPrint(
          '🚕 Booking driver: ${driver.driverName} (ID: ${driver.driverId})',
        );

        // Call the select-driver API
        try {
          await rideViewModel.bookDriver(driver.driverId, fareAmount);
          if (context.mounted) {
            // Close the DriverOffersBottomSheet
            Navigator.pop(context);

            ToastService.showSuccess('Booking confirmed for ${driver.driverName}');
          }
        } catch (error) {
          if (context.mounted) {
            String errorMessage = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
            ToastService.showError('Failed to book driver: $errorMessage');
          }
        }
      },
      onAcceptOffer: (offer) async {
        debugPrint(
          '✅ Accepted offer: ${offer.offerId} from ${offer.driverName}',
        );
        try {
          await rideViewModel.acceptCounterOffer(offer.offerId);
          if (context.mounted) {
            // Close the DriverOffersBottomSheet
            Navigator.pop(context);

            ToastService.showSuccess('Offer accepted successfully');
          }
        } catch (e) {
          if (context.mounted) {
            ToastService.showError('Failed to accept offer: $e');
          }
        }
      },
      onDeclineOffer: (offer) async {
        debugPrint(
          '❌ Declined offer: ${offer.offerId} from ${offer.driverName}',
        );
        try {
          await rideViewModel.declineCounterOffer(offer.offerId);
          if (context.mounted) {
            ToastService.showInfo('Declined offer from ${offer.driverName}');
          }
        } catch (e) {
          debugPrint('Error declining offer: $e');
          if (context.mounted) {
            ToastService.showError('Failed to decline offer');
          }
        }
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ToastService.showError(message);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(appColors: widget.appColors),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
            child: Column(
              children: [
                // Ride Amount Section
                Text(
                  'Your Ride is â‚¦${widget.rideAmount}',
                  style: widget.appFonts.textBaseMedium.copyWith(
                    color: widget.appColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 20.h),

                // Wallet Balance Card
                Consumer<WalletProvider>(
                  builder: (context, walletProvider, _) {
                    final balance =
                        double.tryParse(walletProvider.formattedBalance) ?? 0.0;
                    final rideAmountValue =
                        double.tryParse(widget.rideAmount) ?? 0.0;
                    final hasInsufficientBalance = balance < rideAmountValue;

                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            hasInsufficientBalance
                                ? (widget.appColors.red50)
                                : (widget.appColors.blue50),
                        borderRadius: BorderRadius.circular(16.r),
                        border:
                            hasInsufficientBalance
                                ? Border.all(
                                  color: widget.appColors.red500,
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your Wallet Balance',
                            style: widget.appFonts.textSmRegular.copyWith(
                              color: widget.appColors.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'â‚¦${walletProvider.formattedBalance}',
                            style: widget.appFonts.textBaseMedium.copyWith(
                              color:
                                  hasInsufficientBalance
                                      ? (widget.appColors.red500)
                                      : (widget.appColors.textPrimary),
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (hasInsufficientBalance) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'Insufficient wallet balance',
                              style: widget.appFonts.textSmRegular.copyWith(
                                color: widget.appColors.red500,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 20.h),

                // Action Buttons
                Consumer<WalletProvider>(
                  builder: (context, walletProvider, _) {
                    final balance =
                        double.tryParse(walletProvider.formattedBalance) ?? 0.0;
                    final rideAmountValue =
                        double.tryParse(widget.rideAmount) ?? 0.0;
                    final hasInsufficientBalance = balance < rideAmountValue;

                    return Row(
                      children: [
                        // Book Ride Button with Loading State
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed:
                                  (hasInsufficientBalance || _isBookingRide)
                                      ? null
                                      : () => _handleBookRide(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    (hasInsufficientBalance || _isBookingRide)
                                        ? (widget.appColors.gray200)
                                        : (widget.appColors.blue600),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                disabledBackgroundColor:
                                    widget.appColors.blue600,
                              ),
                              child:
                                  _isBookingRide
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 16.w,
                                            height: 16.h,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Text(
                                            'Creating ride...',
                                            style: widget
                                                .appFonts
                                                .textBaseMedium
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        'Book ride',
                                        style: widget.appFonts.textBaseMedium
                                            .copyWith(
                                              color:
                                                  (hasInsufficientBalance ||
                                                          _isBookingRide)
                                                      ? (widget
                                                          .appColors
                                                          .gray400)
                                                      : Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // Top-up Button
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed:
                                  _isBookingRide
                                      ? null
                                      : () {
                                        Navigator.pop(context);
                                        widget.onTopUp();
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.appColors.gray100,
                                foregroundColor: widget.appColors.textPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                'Top-up',
                                style: widget.appFonts.textBaseMedium.copyWith(
                                  color: widget.appColors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // Ride Details Section
                _buildRideDetailsSection(),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.route, color: widget.appColors.blue600, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'Your ride details',
                style: widget.appFonts.textBaseMedium.copyWith(
                  color: widget.appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // FROM Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: widget.appColors.blue600,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.circle, size: 12.sp, color: Colors.white),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: widget.appFonts.textSmRegular.copyWith(
                        color: widget.appColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.pickup,
                      style: widget.appFonts.textBaseMedium.copyWith(
                        color: widget.appColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Vertical line
          Container(
            width: 2.w,
            height: 24.h,
            margin: EdgeInsets.only(left: 11.w, top: 4.h, bottom: 4.h),
            decoration: BoxDecoration(
              color: widget.appColors.gray300,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),

          // TO Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: widget.appColors.red500,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Going to',
                      style: widget.appFonts.textSmRegular.copyWith(
                        color: widget.appColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.destination,
                      style: widget.appFonts.textBaseMedium.copyWith(
                        color: widget.appColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final AppColorExtension appColors;

  const _DragHandle({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
