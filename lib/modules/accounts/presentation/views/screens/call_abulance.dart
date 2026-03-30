import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/support_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_account_appbar.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_richtext_widget.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class CallAmbulance extends StatefulWidget {
  const CallAmbulance({super.key});

  @override
  State<CallAmbulance> createState() => _CallAmbulanceState();
}

class _CallAmbulanceState extends State<CallAmbulance> {
  @override
  void initState() {
    super.initState();
    _loadAmbulanceServices();
  }

  /// Fetches emergency ambulance service numbers from the server
  Future<void> _loadAmbulanceServices() async {
    final supportProvider = context.read<SupportProvider>();
    await supportProvider.fetchAmbulanceServices();
  }

  /// Launches phone dialer with the provided emergency number
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ToastService.showError('Could not launch phone dialer for $phoneNumber');
      }
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
                title: 'Call an Ambulance',
              ),
              SizedBox(height: 31.h),
              RideNowRichtextWidget(
                firstText: 'Need help? ',
                secondText: 'Here are some emergency numbers you should know!',
                fontSize: 14.sp,
                textAlign: TextAlign.start,
                firstTextColor: appColors.textPrimary,
                secondTextColor: appColors.textPrimary,
                firstTextWeight: FontWeight.w500,
                secondTextWeight: FontWeight.w500,
                appFonts: appFonts,
                appColors: appColors,
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: Consumer<SupportProvider>(
                  builder: (context, supportProvider, child) {
                    if (supportProvider.isLoadingAmbulance) {
                      return _buildShimmerView(appColors);
                    }

                    if (supportProvider.ambulanceState == SupportState.error) {
                      return _buildErrorView(
                        appColors,
                        appFonts,
                        supportProvider,
                      );
                    }

                    final emergencyNumbers = supportProvider.emergencyNumbers;

                    if (emergencyNumbers.isEmpty) {
                      return _buildEmptyView(appColors, appFonts);
                    }

                    return RefreshIndicator(
                      onRefresh: _loadAmbulanceServices,
                      color: appColors.blue500,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: emergencyNumbers.length,
                        separatorBuilder:
                            (context, index) => SizedBox(height: 20.h),
                        itemBuilder: (context, index) {
                          final emergency = emergencyNumbers[index];
                          return _EmergencyNumberCard(
                            emergency: emergency,
                            appColors: appColors,
                            appFonts: appFonts,
                            onCallPressed: _makePhoneCall,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds shimmer loading placeholder for emergency numbers list
  Widget _buildShimmerView(AppColorExtension appColors) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(height: 20.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: appColors.gray100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: appColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 180.w, height: 16.h, borderRadius: 4.r),
              SizedBox(height: 8.h),
              ShimmerBox(
                width: double.infinity,
                height: 14.h,
                borderRadius: 4.r,
              ),
              SizedBox(height: 6.h),
              ShimmerBox(width: 250.w, height: 14.h, borderRadius: 4.r),
              SizedBox(height: 12.h),
              ShimmerBox(width: 140.w, height: 36.h, borderRadius: 8.r),
            ],
          ),
        );
      },
    );
  }

  /// Builds error state view with retry option
  Widget _buildErrorView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    SupportProvider supportProvider,
  ) {
    return RefreshIndicator(
      onRefresh: _loadAmbulanceServices,
      color: appColors.blue500,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  supportProvider.errorMessage ??
                      'Failed to load emergency numbers',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.red600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _loadAmbulanceServices,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state view when no emergency numbers are available
  Widget _buildEmptyView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RefreshIndicator(
      onRefresh: _loadAmbulanceServices,
      color: appColors.blue500,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Text(
              'No emergency numbers available',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card widget displaying a single emergency service with contact details
class _EmergencyNumberCard extends StatelessWidget {
  final dynamic emergency;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final Function(String) onCallPressed;

  const _EmergencyNumberCard({
    required this.emergency,
    required this.appColors,
    required this.appFonts,
    required this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emergency.title,
            style: appFonts.textMdRegular.copyWith(
              color: appColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            emergency.description,
            style: appFonts.textMdRegular.copyWith(
              color: appColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (emergency.phone != null) ...[
            SizedBox(height: 12.h),
            _CallButton(
              phoneNumber: emergency.phone!,
              appColors: appColors,
              appFonts: appFonts,
              onPressed: onCallPressed,
            ),
          ],
          if (emergency.alternativePhone != null) ...[
            SizedBox(height: 8.h),
            _CallButton(
              phoneNumber: emergency.alternativePhone!,
              appColors: appColors,
              appFonts: appFonts,
              onPressed: onCallPressed,
              isAlternative: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Button widget to initiate a phone call to an emergency number
class _CallButton extends StatelessWidget {
  final String phoneNumber;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final Function(String) onPressed;
  final bool isAlternative;

  const _CallButton({
    required this.phoneNumber,
    required this.appColors,
    required this.appFonts,
    required this.onPressed,
    this.isAlternative = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed(phoneNumber),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: appColors.blue500,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Call: $phoneNumber',
              style: appFonts.textSmMedium.copyWith(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
