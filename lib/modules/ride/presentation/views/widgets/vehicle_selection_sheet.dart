// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/amount_bottom_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/vehicle_selection.dart';

class VehicleSelectionSheet {
  static void show(
    BuildContext context, {
    required String destination,
    required String pickup,
    required Function(VehicleType) onVehicleSelected,
    required Function() onTopUp,
  }) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    VehicleType? selectedVehicle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: 550.h,
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
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _DragHandle(appColors: appColors),
                    _SheetTitle(appColors: appColors, appFonts: appFonts),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: VehicleSelectionWidget(
                          onVehicleSelected: (VehicleType vehicle) {
                            setState(() {
                              selectedVehicle = vehicle;
                            });
                            // Call the parent callback
                            onVehicleSelected(vehicle);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed:
                              selectedVehicle != null
                                  ? () {
                                    Navigator.pop(context);

                                    // Show amount bottom sheet WITH pickup
                                    AmountBottomSheet.show(
                                      context,
                                      destination: destination,
                                      pickup: pickup,
                                      onTopUp: onTopUp,
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedVehicle != null
                                    ? appColors.blue600
                                    : appColors.gray200,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            disabledBackgroundColor: appColors.gray200,
                          ),
                          child: Text(
                            'Go',
                            style: appFonts.textBaseMedium.copyWith(
                              color:
                                  selectedVehicle != null
                                      ? Colors.white
                                      : appColors.gray400,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
}

class _SheetTitle extends StatelessWidget {
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  const _SheetTitle({required this.appColors, required this.appFonts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 17.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Select a vehicle',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
