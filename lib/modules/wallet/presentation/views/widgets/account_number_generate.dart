// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';

class AccountNumberGenerator extends StatefulWidget {
  const AccountNumberGenerator({super.key});

  @override
  State<AccountNumberGenerator> createState() => _AccountNumberGeneratorState();
}

class _AccountNumberGeneratorState extends State<AccountNumberGenerator> {
  String? selectedMethod;
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Account number expires in',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Center(
          child: Text(
            '59:52',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.pink500,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        SizedBox(height: 17.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount',
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.gray400,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        5500.0.formatAmountWithCurrency(),
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.blue500,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/copy.svg',
                        color: appColors.blue500,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(color: appColors.gray300),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bank',
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.gray400,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Paystack-Titan Bank',
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.gray600,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(color: appColors.gray300),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Number',
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.gray400,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '0123456789',
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.blue500,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/copy.svg',
                        color: appColors.blue500,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 17.h),

        SizedBox(height: 24.h),
        RideNowButton(
          height: 49.h,
          width: 349.w,
          title: 'I have paid!',
          onTap: () {
            context.pushNamed(RouteConstants.wallet);
          },
        ),
        Spacer(),
      ],
    );
  }
}
