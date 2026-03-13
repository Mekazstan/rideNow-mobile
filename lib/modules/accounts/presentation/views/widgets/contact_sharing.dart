// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_search_bar.dart';

class ContactsAdding extends StatelessWidget {
  const ContactsAdding({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    return Column(
      children: [
        SizedBox(height: 20.h),
        Row(
          children: [
            SvgPicture.asset('assets/contactLocation.svg'),
            SizedBox(width: 10.w),
            Text(
              'Your contacts can watch your ride making it\nsafer for you',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        RideNowSearchBar(hintText: 'Search Contacts'),
        SizedBox(height: 88.h),
        Text(
          'No friend found',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16.h),
        Image.asset('assets/groups.png'),
        Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 49.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: appColors.blue700,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/add.svg',
                    color: appColors.textWhite,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Contacts',
                    style: appFonts.textMdBold.copyWith(
                      color: appColors.textWhite,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 31.h),
      ],
    );
  }
}
