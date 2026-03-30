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
import 'package:ridenowappsss/core/services/toast_service.dart';

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
                if (widget.selectedRide == null)
                  ..._buildRideListView(appColors, appFonts, viewModel)
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

  List<Widget> _buildRideListView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    DriverProvider viewModel,
  ) {
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
      builder: (context) => const DriverLoadingDialogShimmer(),
    );

    final success = await viewModel.acceptRide(widget.selectedRide.id);

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ToastService.showSuccess('Ride accepted! Contact the rider.');
    } else {
      ToastService.showError('Failed to accept ride: ${viewModel.errorMessage}');
    }

    if (success) {
      widget.onBackToList();
    }
  }
}
