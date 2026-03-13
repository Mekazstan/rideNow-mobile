import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/theme/custom_text_styles.dart';

class RideSetupSheet extends StatefulWidget {
  final Function(VehicleType vehicle, double amount) onRideConfirmed;
  final VoidCallback onCancel;

  const RideSetupSheet({
    super.key,
    required this.onRideConfirmed,
    required this.onCancel,
  });

  @override
  State<RideSetupSheet> createState() => _RideSetupSheetState();
}

class _RideSetupSheetState extends State<RideSetupSheet> {
  VehicleType? _selectedVehicle;
  final TextEditingController _amountController = TextEditingController();
  bool _isAmountStep = false;

  final List<_VehicleOption> _vehicles = [
    _VehicleOption(
      type: VehicleType.standard,
      title: 'Standard Ride',
      subtitle: 'Comfort and affordability',
      iconPath: 'assets/standard.svg',
    ),
    _VehicleOption(
      type: VehicleType.luxury,
      title: 'Luxury Vehicle',
      subtitle: 'Ride everywhere in style.',
      iconPath: 'assets/luxury.svg',
    ),
    _VehicleOption(
      type: VehicleType.bike,
      title: 'Bikes',
      subtitle: 'Ride faster, in tight traffic',
      iconPath: 'assets/bike.svg',
    ),
    _VehicleOption(
      type: VehicleType.tricylce,
      title: 'Tricycle',
      subtitle: 'Ride with the wind',
      iconPath: 'assets/tricycle.svg',
    ),
    _VehicleOption(
      type: VehicleType.seaterbus,
      title: 'Seater Bus',
      subtitle: 'More space for more people.',
      iconPath: 'assets/bus.svg',
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_selectedVehicle == null) return;
    setState(() {
      _isAmountStep = true;
    });
  }

  void _onBook() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    widget.onRideConfirmed(_selectedVehicle!, amount);
  }

  @override
  Widget build(BuildContext context) {
    // Assuming Theme extensions are available
    final appColors = Theme.of(context).extension<AppColorExtension>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      constraints: BoxConstraints(maxHeight: 600.h),
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
                _isAmountStep ? 'Enter your offer' : 'Select a vehicle',
                style: CustomTextStyles.headerMedium,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Content
          Expanded(
            child:
                _isAmountStep
                    ? _buildAmountInput()
                    : _buildVehicleList(appColors),
          ),

          // Footer Button
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed:
                        _isAmountStep
                            ? _onBook
                            : (_selectedVehicle != null ? _onContinue : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF), // Blue
                      disabledBackgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      _isAmountStep ? 'Book Ride' : 'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (_isAmountStep) ...[
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () => setState(() => _isAmountStep = false),
                    child: const Text('Back to Vehicle Selection'),
                  ),
                ] else ...[
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(AppColorExtension? appColors) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                      : Colors.transparent, // blue50
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color:
                    isSelected
                        ? const Color(0xFF0066FF)
                        : Colors.grey[300]!, // blue500
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
                              ? const Color(0xFF0066FF)
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
                              color: Color(0xFF0066FF),
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
                // Icon placeholder (using Icon until assets are confirmed working)
                const Icon(Icons.directions_car, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₦ ',
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter the amount you are willing to pay',
            style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

class _VehicleOption {
  final VehicleType type;
  final String title;
  final String subtitle;
  final String iconPath;

  _VehicleOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.iconPath,
  });
}
