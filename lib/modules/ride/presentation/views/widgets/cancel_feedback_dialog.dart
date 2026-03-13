// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class CancelFeedbackDialog extends StatefulWidget {
  final Function(String reason, String otherReason) onSubmit;
  final VoidCallback onBack;

  const CancelFeedbackDialog({
    super.key,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<CancelFeedbackDialog> createState() => _CancelFeedbackDialogState();
}

class _CancelFeedbackDialogState extends State<CancelFeedbackDialog> {
  String _selectedReason = 'I felt endangered by the driver';
  final TextEditingController _otherReasonController = TextEditingController();

  final List<String> _reasons = [
    'I felt endangered by the driver',
    'Changed my location',
    'No reason',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Icon(
                    Icons.close,
                    color: appColors.gray400,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              "Why did you cancel your ride?",
              style: appFonts.textBaseMedium.copyWith(
                color: const Color(0xFF424242),
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24.h),
            ..._reasons.map(
              (reason) => _buildReasonItem(reason, appColors, appFonts),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: TextField(
                controller: _otherReasonController,
                decoration: InputDecoration(
                  hintText: 'Other reasons',
                  hintStyle: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: 3,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => widget.onSubmit(
                          _selectedReason,
                          _otherReasonController.text,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFD81B60,
                      ), // Pink shade from image
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3F51B5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'No, go back',
                      style: TextStyle(
                        color: const Color(0xFF1A237E),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(
    String reason,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    bool isSelected = _selectedReason == reason;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? const Color(0xFF3F51B5)
                          : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3F51B5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      : null,
            ),
            SizedBox(width: 12.w),
            Text(
              reason,
              style: TextStyle(
                color: const Color(0xFF4B5563),
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }
}
