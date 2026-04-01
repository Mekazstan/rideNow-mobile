// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/amount_bottom_sheet.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/vehicle_selection.dart';

class VehicleSelectionSheet extends StatefulWidget {
  final String destination;
  final String pickup;
  final Function(VehicleType) onVehicleSelected;
  final Function() onTopUp;
  final VoidCallback? onDismiss;

  const VehicleSelectionSheet({
    super.key,
    required this.destination,
    required this.pickup,
    required this.onVehicleSelected,
    required this.onTopUp,
    this.onDismiss,
  });

  @override
  State<VehicleSelectionSheet> createState() => _VehicleSelectionSheetState();
}

class _VehicleSelectionSheetState extends State<VehicleSelectionSheet> {
  VehicleType? _selectedVehicle;
  final DraggableScrollableController _controller = DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.55,
      minChildSize: 0.1,
      maxChildSize: 0.85,
      snap: true,
      builder: (context, scrollController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMinimized = constraints.maxHeight < 150.h;
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Drag Handle
                      _DragHandle(appColors: appColors),
                      
                      // Title Area - Hide if minimized
                      if (!isMinimized)
                        _SheetTitle(appColors: appColors, appFonts: appFonts),
                      
                      // Content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          children: [
                            VehicleSelectionWidget(
                              onVehicleSelected: (VehicleType vehicle) {
                                setState(() {
                                  _selectedVehicle = vehicle;
                                });
                                widget.onVehicleSelected(vehicle);
                              },
                            ),
                            // Space for the floating button if not minimized
                            if (!isMinimized) SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Floating Button at bottom
                  if (!isMinimized)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.3],
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: _selectedVehicle != null
                                ? () {
                                    // Show amount bottom sheet
                                    AmountBottomSheet.show(
                                      context,
                                      destination: widget.destination,
                                      pickup: widget.pickup,
                                      onTopUp: widget.onTopUp,
                                    );
                                    if (widget.onDismiss != null) widget.onDismiss!();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedVehicle != null
                                  ? appColors.blue600
                                  : appColors.gray200,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Go',
                              style: appFonts.textBaseMedium.copyWith(
                                color: _selectedVehicle != null
                                    ? Colors.white
                                    : appColors.gray400,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
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
        margin: EdgeInsets.symmetric(vertical: 12.h),
        width: 40.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.5.r),
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
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Select a vehicle',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
