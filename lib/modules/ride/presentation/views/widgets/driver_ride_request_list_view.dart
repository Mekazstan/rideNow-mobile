import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/driver_screenshimmer.dart';
class RideRequestsListView extends StatelessWidget {
  final DriverProvider viewModel;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final Function(dynamic) onRideSelected;
  final TextEditingController searchController;
  final Future<void> Function()? onRefresh;

  const RideRequestsListView({
    super.key,
    required this.viewModel,
    required this.appColors,
    required this.appFonts,
    required this.onRideSelected,
    required this.searchController,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const DriverRideRequestsListShimmer();
    }

    if (viewModel.hasError) {
      return _buildErrorState(context);
    }

    final requests = viewModel.filteredRequests;

    if (requests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () => viewModel.refresh(),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: requests.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final request = requests[index];
          return RideRequestItem(
            request: request,
            onTap: () => onRideSelected(request),
            appColors: appColors,
            appFonts: appFonts,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isUnverified = viewModel.errorMessage?.contains('No active and verified vehicle found') == true ||
        viewModel.errorMessage?.contains('DRIVER_VERIFICATION_REQUIRED') == true;

    if (isUnverified) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pending_actions, size: 48.sp, color: appColors.orange500),
              SizedBox(height: 12.h),
              Text(
                'Pending Admin Approval',
                textAlign: TextAlign.center,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Your profile is currently under review. You will be notified once it is approved.',
                  textAlign: TextAlign.center,
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed(RouteConstants.driverVerificationPortal);
                },
                icon: Icon(Icons.remove_red_eye, size: 18.sp),
                label: const Text('View Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.blue600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: appColors.red500),
            SizedBox(height: 12.h),
            Text(
              'Error Loading Rides',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              viewModel.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRefresh ?? () => viewModel.fetchRideRequests(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.blue600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48.sp, color: appColors.gray300),
          SizedBox(height: 12.h),
          Text(
            'No ride requests available',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class RideRequestItem extends StatelessWidget {
  final dynamic request;
  final VoidCallback onTap;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  const RideRequestItem({
    super.key,
    required this.request,
    required this.onTap,
    required this.appColors,
    required this.appFonts,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationRow(),
            SizedBox(height: 12.h),
            _buildRiderInfoRow(),
            SizedBox(height: 8.h),
            _buildTimeStamp(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        SvgPicture.asset('assets/userLocation.svg', width: 16.w, height: 16.h),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            request.destinationLocation,
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRiderInfoRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundImage:
              request.riderImage.isNotEmpty
                  ? NetworkImage(request.riderImage)
                  : null,
          child:
              request.riderImage.isEmpty
                  ? Icon(Icons.person, size: 20.sp)
                  : null,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.riderName,
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (request.isVerified)
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/verify.svg',
                      width: 12.w,
                      height: 12.h,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Verified',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.pink500,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (request.getRiderRatingDisplay() != 'N/A')
          Row(
            children: [
              SvgPicture.asset('assets/badge.svg', width: 16.w, height: 16.h),
              SizedBox(width: 6.w),
              Text(
                request.getRiderRatingDisplay(),
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.green700,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        SizedBox(width: 12.w),
        Text(
          request.getFormattedFare(),
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStamp() {
    return Text(
      request.getTimeSinceCreated(),
      style: appFonts.textSmMedium.copyWith(
        color: appColors.textPrimary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
