import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';

class FixedBottomSection extends StatefulWidget {
  final VoidCallback? onGoPressed;

  const FixedBottomSection({super.key, this.onGoPressed});

  @override
  State<FixedBottomSection> createState() => _FixedBottomSectionState();
}

class _FixedBottomSectionState extends State<FixedBottomSection> {
  final TextEditingController _paymentController = TextEditingController();

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: RidenowTextfield(
                  showFieldName: false,
                  fieldName: '',
                  hintText: 'What do you want to pay?',
                  controller: _paymentController,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: widget.onGoPressed,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: appColors.blue600,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/go.svg'),
                        SizedBox(width: 8.w),
                        Text(
                          'Go',
                          style: appFonts.textSmMedium.copyWith(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'No coupons to apply',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.gray200,
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
