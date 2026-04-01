import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_api_models.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    await context.read<RideProvider>().fetchRideHistory();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      backgroundColor: appColors.bgB0,
      appBar: AppBar(
        backgroundColor: appColors.bgB0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: appColors.textPrimary, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Rides',
          style: appFonts.textMdMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: appColors.blue500,
          labelColor: appColors.blue500,
          unselectedLabelColor: appColors.gray500,
          labelStyle: appFonts.textSmMedium.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentRides(appColors, appFonts),
          _buildPastRides(appColors, appFonts),
        ],
      ),
    );
  }

  Widget _buildCurrentRides(AppColorExtension appColors, AppFontThemeExtension appFonts) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        if (!rideProvider.isRideActive) {
          return _buildEmptyState(
            appColors,
            appFonts,
            'No active rides',
            'You don\'t have any ongoing rides at the moment.',
            Icons.directions_car_filled_outlined,
          );
        }

        return ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _buildRideCard(
              appColors,
              appFonts,
              pickup: rideProvider.pickupLocation?.address ?? 'Current Location',
              destination: rideProvider.destinationLocation?.address ?? 'Fetching destination...',
              status: rideProvider.rideStage.toString().split('.').last,
              date: 'Ongoing',
              price: 'Calculated at end',
              isActive: true,
              onTap: () => context.pop(), // Go back to map/active ride UI
            ),
          ],
        );
      },
    );
  }

  Widget _buildPastRides(AppColorExtension appColors, AppFontThemeExtension appFonts) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        if (_isLoading) {
          return _buildLoadingList();
        }

        final history = rideProvider.rideHistory;
        if (history.isEmpty) {
          return _buildEmptyState(
            appColors,
            appFonts,
            'No ride history',
            'You haven\'t taken any rides yet. Book your first ride now!',
            Icons.history_rounded,
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(20.w),
          itemCount: history.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final ride = history[index];
            return _buildRideCard(
              appColors,
              appFonts,
              pickup: ride.pickupLocation.address,
              destination: ride.destination.address,
              status: ride.status.replaceAll('_', ' ').toUpperCase(),
              date: DateFormat('MMM dd, yyyy • hh:mm a').format(
                DateTime.parse(ride.createdAt),
              ),
              price: '₦${NumberFormat('#,###').format(ride.fare)}',
              isActive: false,
            );
          },
        );
      },
    );
  }

  Widget _buildRideCard(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts, {
    required String pickup,
    required String destination,
    required String status,
    required String date,
    required String price,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: appColors.bgB0,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isActive ? appColors.blue500 : appColors.blue100),
          boxShadow: [
            BoxShadow(
              color: appColors.blue500.withOpacity(isActive ? 0.08 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isActive ? appColors.blue100 : appColors.gray100,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: appFonts.textXsMedium.copyWith(
                      color: isActive ? appColors.blue600 : appColors.gray600,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: appFonts.textXsMedium.copyWith(
                    color: appColors.gray500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.circle, size: 12.sp, color: appColors.blue500),
                    Container(height: 20.h, width: 1.w, color: appColors.blue100),
                    Icon(Icons.location_on, size: 14.sp, color: appColors.red500),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appFonts.textSmMedium.copyWith(color: appColors.textPrimary),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appFonts.textSmMedium.copyWith(color: appColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: appColors.blue100, height: 1),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fare',
                  style: appFonts.textSmMedium.copyWith(color: appColors.gray500),
                ),
                Text(
                  price,
                  style: appFonts.textMdMedium.copyWith(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: appColors.blue50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40.sp, color: appColors.blue500),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: appFonts.textMdMedium.copyWith(
              color: appColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: appFonts.textSmMedium.copyWith(color: appColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) => ShimmerBox(
        width: double.infinity,
        height: 160.h,
        borderRadius: 16.r,
      ),
    );
  }
}
