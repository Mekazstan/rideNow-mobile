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
      icon: 'assets/standard.svg',
    ),
    VehicleOption(
      type: VehicleType.luxury,
      title: 'Luxury Vehicle',
      subtitle: 'Ride everywhere in style.',
      icon: 'assets/luxury.svg',
    ),
    VehicleOption(
      type: VehicleType.bike,
      title: 'Bikes',
      subtitle: 'Ride faster, in tight traffic',
      icon: 'assets/bike.svg',
    ),
    VehicleOption(
      type: VehicleType.tricylce,
      title: 'Tricycle',
      subtitle: 'Ride with the wind',
      icon: 'assets/tricycle.svg',
    ),
    VehicleOption(
      type: VehicleType.seaterbus,
      title: 'Seater Bus',
      subtitle: 'More space for more people.',
      icon: 'assets/bus.svg',
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
                  height: 103.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected ? appColors.blue50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: appColors.blue200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? appColors.blue500
                                        : appColors.gray300,
                                width: 2.w,
                              ),
                              color: Colors.transparent,
                            ),
                            child:
                                isSelected
                                    ? Container(
                                      margin: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appColors.blue500,
                                      ),
                                    )
                                    : null,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.title,
                                  style: appFonts.textSmMedium.copyWith(
                                    color: appColors.textPrimary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  vehicle.subtitle,
                                  style: appFonts.textSmMedium.copyWith(
                                    color: appColors.textSecondary,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
