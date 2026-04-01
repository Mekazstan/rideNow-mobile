import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class VehicleSelectionWidget extends StatefulWidget {
  final Function(VehicleType) onVehicleSelected;

  const VehicleSelectionWidget({super.key, required this.onVehicleSelected});

  @override
  State<VehicleSelectionWidget> createState() => _VehicleSelectionWidgetState();
}

class _VehicleSelectionWidgetState extends State<VehicleSelectionWidget> {
  VehicleType? selectedVehicle;

  final List<VehicleOption> vehicles = [
    VehicleOption(
      type: VehicleType.standard,
      title: 'Standard Ride',
      subtitle: 'Comfort and affordability',
      icon: 'assets/standardride.png',
    ),
    VehicleOption(
      type: VehicleType.luxury,
      title: 'Luxury Vehicle',
      subtitle: 'Ride everywhere in style.',
      icon: 'assets/luxury.png',
    ),
    VehicleOption(
      type: VehicleType.bike,
      title: 'Bikes',
      subtitle: 'Ride faster, in tight traffic',
      icon: 'assets/bike.png',
    ),
    VehicleOption(
      type: VehicleType.tricylce,
      title: 'Tricycle',
      subtitle: 'Ride with the wind',
      icon: 'assets/tricycle.png',
    ),
    VehicleOption(
      type: VehicleType.seaterbus,
      title: 'Seater Bus',
      subtitle: 'More space for more people.',
      icon: 'assets/seaterbus.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      children:
          vehicles.map((vehicle) {
            final isSelected = selectedVehicle == vehicle.type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedVehicle = vehicle.type;
                });
                widget.onVehicleSelected(vehicle.type);
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected ? appColors.blue50 : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? appColors.blue600 : appColors.gray200,
                      width: isSelected ? 2.w : 1.w,
                    ),
                    boxShadow: [
                      if (isSelected) 
                        BoxShadow(
                          color: appColors.blue600.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left Section: Radio and Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Radio Indicator
                            Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? appColors.blue600
                                      : appColors.gray300,
                                  width: 2.w,
                                ),
                                color: Colors.transparent,
                              ),
                              child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 10.w,
                                      height: 10.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appColors.blue600,
                                      ),
                                    ),
                                  )
                                : null,
                            ),
                            SizedBox(height: 12.h),
                            // Vehicle Info
                            Text(
                              vehicle.title,
                              style: appFonts.textSmMedium.copyWith(
                                color: appColors.textPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              vehicle.subtitle,
                              style: appFonts.textSmMedium.copyWith(
                                color: appColors.textSecondary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right Section: Image
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 110.w,
                        height: 70.h,
                        child: vehicle.icon.endsWith('.svg')
                          ? Image.asset(vehicle.icon) // Fallback for now if needed, though they are pngs
                          : Image.asset(
                              vehicle.icon,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.car_repair, size: 40.sp, color: appColors.gray300);
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

/// Model class for vehicle options
class VehicleOption {
  final VehicleType type;
  final String title;
  final String subtitle;
  final String icon;

  VehicleOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
