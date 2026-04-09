// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_ride_details_view.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_ride_request_list_view.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_screenshimmer.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_counter_offer_sheet.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:go_router/go_router.dart';

class RideRequestBottomSheet extends StatefulWidget {
  final String currentLocationName;
  final dynamic selectedRide;
  final Function(dynamic) onRideSelected;
  final VoidCallback onBackToList;
  final Future<void> Function()? onRefresh;

  const RideRequestBottomSheet({
    super.key,
    required this.currentLocationName,
    this.selectedRide,
    required this.onRideSelected,
    required this.onBackToList,
    this.onRefresh,
  });

  @override
  State<RideRequestBottomSheet> createState() => _RideRequestBottomSheetState();
}

class _RideRequestBottomSheetState extends State<RideRequestBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      constraints: BoxConstraints(
        minHeight: 320.h,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Consumer<DriverProvider>(
        builder: (context, viewModel, _) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(appColors),
                SizedBox(height: 24.h),
                if (viewModel.hasPendingCounterOffer)
                  ..._buildAwaitingView(appColors, appFonts, viewModel)
                else if (widget.selectedRide == null)
                  ..._buildRideRequestsView(appColors, appFonts, viewModel)
                else
                  ..._buildRideDetailsView(appColors, appFonts, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragHandle(AppColorExtension appColors) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  List<Widget> _buildAwaitingView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    DriverProvider viewModel,
  ) {
    return [
      Center(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            const CircularProgressIndicator(),
            SizedBox(height: 20.h),
            Text(
              'Awaiting Rider Acceptance',
              style: appFonts.textMdBold.copyWith(color: appColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              'You offered ₦${viewModel.pendingCounterOfferAmount?.toStringAsFixed(2)}',
              style: appFonts.textSmMedium.copyWith(color: appColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => viewModel.clearPendingCounterOffer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Cancel Offer'),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildRideRequestsView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    DriverProvider viewModel,
  ) {
    if (viewModel.isVerificationStatusLoaded && !viewModel.isApproved) {
      return [_buildUnapprovedState(appColors, appFonts, viewModel)];
    }

    return [
      _buildHeader(appColors, appFonts, viewModel),
      SizedBox(height: 10.h),
      _buildSearchBar(appColors, appFonts, viewModel),
      SizedBox(height: 20.h),
      Expanded(
        child: RideRequestsListView(
          viewModel: viewModel,
          appColors: appColors,
          appFonts: appFonts,
          onRideSelected: widget.onRideSelected,
          searchController: _searchController,
          onRefresh: widget.onRefresh,
        ),
      ),
    ];
  }

  List<Widget> _buildRideDetailsView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    DriverProvider viewModel,
  ) {
    return [
      Expanded(
        child: RideDetailsView(
          ride: widget.selectedRide,
          appColors: appColors,
          appFonts: appFonts,
          currentLocationName: widget.currentLocationName,
          onBack: widget.onBackToList,
          onAccept: () => _handleAcceptRide(viewModel),
          onCounterOffer: () => _handleCounterOffer(context, viewModel),
        ),
      ),
    ];
  }

  Widget _buildHeader(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    DriverProvider viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's find a rider",
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "${viewModel.ridesRemaining} rides remaining today",
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        IconButton(
          icon:
              viewModel.isRefreshing
                  ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: appColors.blue600,
                    ),
                  )
                  : SvgPicture.asset('assets/refresh.svg'),
          onPressed:
              viewModel.isRefreshing
                  ? null
                  : () {
                    if (widget.onRefresh != null) {
                      widget.onRefresh!();
                    } else {
                      viewModel.refresh();
                    }
                  },
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    DriverProvider viewModel,
  ) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: appColors.gray50,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: appColors.gray200),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => viewModel.searchRideRequests(value),
        style: appFonts.textSmMedium.copyWith(
          color: appColors.textPrimary,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Search by location',
          hintStyle: appFonts.textSmMedium.copyWith(
            color: appColors.textSecondary,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: appColors.textSecondary,
            size: 20.sp,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Future<void> _handleAcceptRide(DriverProvider viewModel) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const DriverLoadingDialogShimmer(),
    );

    final success = await viewModel.acceptRide(widget.selectedRide.id);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (success) {
      ToastService.showSuccess('Ride accepted! Contact the rider.');
      // Wait for dialog dismiss animation to fully complete before updating map constraints
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        widget.onBackToList();
      }
    } else {
      ToastService.showError('Failed to accept ride: ${viewModel.errorMessage}');
    }
  }

  void _handleCounterOffer(BuildContext context, DriverProvider viewModel) {
    if (widget.selectedRide == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DriverCounterOfferSheet(
        currentFare: widget.selectedRide.fare.toDouble(),
        onOfferSent: (newFare) async {
          Navigator.pop(sheetContext); // Close the bottom sheet first
          
          showDialog(
            context: context, // Use the outer, still-mounted context
            barrierDismissible: false,
            builder: (dialogContext) => const DriverLoadingDialogShimmer(),
          );
          
          final success = await viewModel.sendCounterOffer(
            widget.selectedRide.id,
            newFare,
          );
          
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog explicitly
          
          if (success) {
            ToastService.showSuccess('Counter offer sent!');
            // Wait for dialog dismiss animation to fully complete before going to list view logic
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              widget.onBackToList();
            }
          } else {
            ToastService.showError(viewModel.errorMessage ?? 'Failed to send counter offer');
          }
        },
      ),
    );
  }

  Widget _buildUnapprovedState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    DriverProvider viewModel,
  ) {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: appColors.orange50.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pending_actions_rounded,
                  size: 64.sp,
                  color: appColors.orange500,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Verification Pending',
                textAlign: TextAlign.center,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'Your driver profile is currently under review by our admin team. This usually takes 24-48 hours.',
                  textAlign: TextAlign.center,
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.textSecondary,
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed(RouteConstants.driverVerificationPortal);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.blue600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye_outlined, size: 20.sp),
                    SizedBox(width: 8.w),
                    const Text('View Application Status'),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => viewModel.refresh(),
                child: Text(
                  'Refresh Status',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.blue600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
