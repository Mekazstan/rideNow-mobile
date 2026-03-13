// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/watch_ride_content.dart';

class WatchRide extends StatelessWidget {
  const WatchRide({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      children: [
        SizedBox(height: 20.h),
        Expanded(
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 13.h),
                child: WatchRideContent(
                  appColors: appColors,
                  appFonts: appFonts,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
