// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/data/models/police_models.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/support_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_account_appbar.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_richtext_widget.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_search_bar.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CallPolice extends StatefulWidget {
  const CallPolice({super.key});

  @override
  State<CallPolice> createState() => _CallPoliceState();
}

class _CallPoliceState extends State<CallPolice> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadPoliceStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches police stations from the server, optionally filtered by location
  Future<void> _loadPoliceStations({String? location}) async {
    final supportProvider = context.read<SupportProvider>();
    await supportProvider.fetchPoliceStations(location: location);
    if (mounted) {
      setState(() => _hasSearched = true);
    }
  }

  /// Handles search submission and triggers police station lookup
  Future<void> _onSearch() async {
    final location = _searchController.text.trim();
    if (location.isEmpty) return;

    FocusScope.of(context).unfocus();
    await _loadPoliceStations(location: location);
  }

  /// Launches phone dialer with the provided police station number
  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              RideNowAccountAppBar(
                appFonts: appFonts,
                appColors: appColors,
                title: 'Call Police',
              ),
              SizedBox(height: 31.h),
              RideNowRichtextWidget(
                firstText: 'Need help? ',
                secondText:
                    'Enter a location and get the closest stations near you.',
                fontSize: 16.sp,
                textAlign: TextAlign.start,
                firstTextColor: appColors.textPrimary,
                secondTextColor: appColors.textPrimary,
                firstTextWeight: FontWeight.w400,
                secondTextWeight: FontWeight.w700,
                appFonts: appFonts,
                appColors: appColors,
              ),
              SizedBox(height: 8.h),
              RideNowSearchBar(
                hintText: 'Enter location',
                controller: _searchController,
                onSubmitted: (_) => _onSearch(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: appColors.textSecondary),
                  onPressed: _onSearch,
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(child: _buildContent(appColors, appFonts)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds appropriate content based on loading, error, or data state
  Widget _buildContent(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Consumer<SupportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPolice) {
          return _buildShimmerLoading();
        }

        if (provider.policeState == SupportState.error) {
          return _buildErrorState(appColors, appFonts, provider);
        }

        if (!_hasSearched) {
          return _buildEmptyState(
            appColors,
            appFonts,
            'Enter a location to find nearby police stations',
          );
        }

        if (provider.policeStations.isEmpty) {
          return _buildEmptyState(
            appColors,
            appFonts,
            'No police stations found for this location',
          );
        }

        return _buildStationsList(appColors, appFonts, provider);
      },
    );
  }

  /// Builds shimmer loading placeholder for police stations list
  Widget _buildShimmerLoading() {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).extension<AppColorExtension>()!.blue200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 200.w, height: 18.h, borderRadius: 4.r),
              SizedBox(height: 8.h),
              ShimmerBox(
                width: double.infinity,
                height: 14.h,
                borderRadius: 4.r,
              ),
              SizedBox(height: 4.h),
              ShimmerBox(width: 150.w, height: 14.h, borderRadius: 4.r),
            ],
          ),
        );
      },
    );
  }

  /// Builds error state view with retry option
  Widget _buildErrorState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    SupportProvider provider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: appColors.red500),
          SizedBox(height: 16.h),
          Text(
            provider.errorMessage ?? 'Failed to load police stations',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textSecondary,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed:
                () => _loadPoliceStations(
                  location: _searchController.text.trim(),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.blue500,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            ),
            child: Text(
              'Retry',
              style: appFonts.textSmMedium.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state view with custom message
  Widget _buildEmptyState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/safety.svg',
            width: 80.w,
            height: 80.h,
            color: appColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textSecondary,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds scrollable list of police stations
  Widget _buildStationsList(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    SupportProvider provider,
  ) {
    return ListView.separated(
      itemCount: provider.policeStations.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final station = provider.policeStations[index];
        return _buildStationCard(appColors, appFonts, station);
      },
    );
  }

  /// Builds a single police station card with contact button
  Widget _buildStationCard(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    PoliceStation station,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appColors.blue200, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: appColors.blue500,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        station.address,
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (station.phone != null) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () => _makePhoneCall(station.phone!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: appColors.green500, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 16.sp, color: appColors.green500),
                    SizedBox(width: 6.w),
                    Text(
                      'Call',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.green500,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
