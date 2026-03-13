import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class FindingDriverSheet extends StatelessWidget {
  final VoidCallback onCancel;

  const FindingDriverSheet({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(appColors),
          SizedBox(height: 24.h),
          Text(
            'Finding your driver...',
            style: appFonts.textBaseMedium.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'This might take a few moments as we connect you with nearby drivers.',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.textSecondary,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          _buildPulseIndicator(appColors),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: appColors.red500, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Cancel Request',
                style: appFonts.textBaseMedium.copyWith(
                  color: appColors.red500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle(AppColorExtension appColors) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildPulseIndicator(AppColorExtension appColors) {
    return SizedBox(
      height: 4.h,
      child: LinearProgressIndicator(
        backgroundColor: appColors.blue50,
        valueColor: AlwaysStoppedAnimation<Color>(appColors.blue600),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
