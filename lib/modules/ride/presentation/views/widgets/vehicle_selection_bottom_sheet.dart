import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';

class VehicleSelectionBottomSheet extends StatefulWidget {
  final Function(VehicleType) onVehicleSelected;

  const VehicleSelectionBottomSheet({
    super.key,
    required this.onVehicleSelected,
  });

  @override
  State<VehicleSelectionBottomSheet> createState() =>
      _VehicleSelectionBottomSheetState();
}

class _VehicleSelectionBottomSheetState
    extends State<VehicleSelectionBottomSheet> {
  VehicleType? _selectedVehicle;

  final List<_VehicleOption> _vehicles = [
    _VehicleOption(
      type: VehicleType.standard,
      title: 'Standard Ride',
      subtitle: 'Comfort and affordability',
      icon: Icons.directions_car,
    ),
    _VehicleOption(
      type: VehicleType.luxury,
      title: 'Luxury Vehicle',
      subtitle: 'Ride everywhere in style',
      icon: Icons.directions_car,
    ),
    _VehicleOption(
      type: VehicleType.bike,
      title: 'Bikes',
      subtitle: 'Ride faster, in tight traffic',
      icon: Icons.two_wheeler,
    ),
    _VehicleOption(
      type: VehicleType.tricylce,
      title: 'Tricycle',
      subtitle: 'Ride with the wind',
      icon: Icons.pedal_bike,
    ),
    _VehicleOption(
      type: VehicleType.seaterbus,
      title: 'Seater Bus',
      subtitle: 'More space for more people',
      icon: Icons.airport_shuttle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select a vehicle',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Vehicle List
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              shrinkWrap: true,
              itemCount: _vehicles.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                final isSelected = _selectedVehicle == vehicle.type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVehicle = vehicle.type),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFEFF6FF)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF4285F4)
                                : Colors.grey[300]!,
                        width: isSelected ? 2.w : 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio Circle
                        Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFF4285F4)
                                      : Colors.grey[400]!,
                              width: 2.w,
                            ),
                          ),
                          padding: EdgeInsets.all(3.w),
                          child:
                              isSelected
                                  ? Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4285F4),
                                    ),
                                  )
                                  : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                vehicle.subtitle,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          vehicle.icon,
                          color: Colors.grey[600],
                          size: 28.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Continue Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed:
                    _selectedVehicle != null
                        ? () => widget.onVehicleSelected(_selectedVehicle!)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  disabledBackgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _VehicleOption {
  final VehicleType type;
  final String title;
  final String subtitle;
  final IconData icon;

  _VehicleOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
