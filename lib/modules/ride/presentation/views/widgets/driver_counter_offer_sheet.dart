import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class DriverCounterOfferSheet extends StatefulWidget {
  final double currentFare;
  final Function(double) onOfferSent;

  const DriverCounterOfferSheet({
    super.key,
    required this.currentFare,
    required this.onOfferSent,
  });

  @override
  State<DriverCounterOfferSheet> createState() => _DriverCounterOfferSheetState();
}

class _DriverCounterOfferSheetState extends State<DriverCounterOfferSheet> {
  late TextEditingController _fareController;
  late double _proposedFare;

  @override
  void initState() {
    super.initState();
    _proposedFare = widget.currentFare;
    _fareController = TextEditingController(text: _proposedFare.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _fareController.dispose();
    super.dispose();
  }

  void _updateFare(double amount) {
    setState(() {
      _proposedFare += amount;
      _fareController.text = _proposedFare.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: appColors.gray300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Negotiate Fare',
            style: appFonts.heading3Bold,
          ),
          SizedBox(height: 8.h),
          Text(
            'Suggest a new price for this ride.',
            style: appFonts.textSmRegular.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 32.h),
          
          // Fare Input Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: appColors.gray50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: appColors.gray200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₦',
                  style: appFonts.heading1Bold.copyWith(color: appColors.brandDefault),
                ),
                SizedBox(width: 8.w),
                IntrinsicWidth(
                  child: TextField(
                    controller: _fareController,
                    keyboardType: TextInputType.number,
                    style: appFonts.heading1Bold,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null) _proposedFare = val;
                    },
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Quick Increments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAddButton('+100', 100, appColors, appFonts),
              _buildQuickAddButton('+200', 200, appColors, appFonts),
              _buildQuickAddButton('+500', 500, appColors, appFonts),
            ],
          ),
          
          SizedBox(height: 40.h),
          
          // Action Button
          RideNowButton(
            title: 'Send Counter Offer',
            onTap: () => widget.onOfferSent(_proposedFare),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String label, double amount, AppColorExtension appColors, AppFontThemeExtension appFonts) {
    return GestureDetector(
      onTap: () => _updateFare(amount),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: appColors.gray200),
        ),
        child: Text(
          label,
          style: appFonts.textSmMedium.copyWith(color: appColors.textPrimary),
        ),
      ),
    );
  }
}
