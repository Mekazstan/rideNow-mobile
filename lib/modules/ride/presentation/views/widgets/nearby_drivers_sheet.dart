import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/available_drvers.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_loading.dart';

class NearbyDriversSheet extends StatelessWidget {
  final List<AvailableDriver> drivers;
  final bool isLoading;
  final Function(AvailableDriver) onSelectDriver;

  const NearbyDriversSheet({
    super.key,
    required this.drivers,
    this.isLoading = false,
    required this.onSelectDriver,
  });

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
      constraints: BoxConstraints(maxHeight: 0.6.sh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(appColors),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Drivers',
                  style: appFonts.textBaseBold.copyWith(
                    color: appColors.textPrimary,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (isLoading)
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
                itemCount: 4,
                itemBuilder: (context, index) => const ShimmerListTile(),
              ),
            )
          else if (drivers.isEmpty)
            Padding(
              padding: EdgeInsets.all(40.w),
              child: Text(
                'Searching for drivers nearby...',
                style: appFonts.textSmRegular.copyWith(
                  color: appColors.textSecondary,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
                itemCount: drivers.length,
                separatorBuilder:
                    (context, index) =>
                        Divider(height: 1, color: appColors.gray200),
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundImage:
                          driver.imageUrl != null
                              ? NetworkImage(driver.imageUrl!)
                              : null,
                      onBackgroundImageError: driver.imageUrl != null 
                          ? (exception, stackTrace) {} 
                          : null,
                      child:
                          driver.imageUrl == null
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          driver.driverName,
                          style: appFonts.textSmMedium.copyWith(
                            color: appColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.star, color: Colors.amber, size: 14.sp),
                        SizedBox(width: 2.w),
                        Text(
                          driver.rating.toString(),
                          style: appFonts.textSmRegular.copyWith(
                            color: appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${driver.vehicle?.make ?? 'Vehicle'} • ${driver.estimatedTime}',
                      style: appFonts.textSmRegular.copyWith(
                        color: appColors.textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: appColors.gray400,
                    ),
                    onTap: () => onSelectDriver(driver),
                  );
                },
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
}
