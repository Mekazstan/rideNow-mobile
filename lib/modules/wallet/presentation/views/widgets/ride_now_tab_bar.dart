import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RideNowTabBar extends StatefulWidget {
  const RideNowTabBar({
    super.key,
    required this.firstTabText,
    required this.secondTabText,
    required this.firstTabContent,
    required this.secondTabContent,
    required this.appFonts,
    required this.appColors,
    this.initialTabIndex = 0,
  });

  final String firstTabText;
  final String secondTabText;
  final Widget firstTabContent;
  final Widget secondTabContent;
  final AppFontThemeExtension appFonts;
  final AppColorExtension appColors;
  final int initialTabIndex;

  @override
  State<RideNowTabBar> createState() => _RideNowTabBarState();
}

class _RideNowTabBarState extends State<RideNowTabBar> {
  late int selectedTabIndex;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTabIndex = 0),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            selectedTabIndex == 0
                                ? appColors.blue500
                                : appColors.gray300,
                        width: 2.w,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.firstTabText,
                    textAlign: TextAlign.center,
                    style: widget.appFonts.textSmMedium.copyWith(
                      color:
                          selectedTabIndex == 0
                              ? appColors.blue500
                              : appColors.gray300,
                      fontSize: 16.sp,
                      fontWeight:
                          selectedTabIndex == 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTabIndex = 1),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            selectedTabIndex == 1
                                ? appColors.blue500
                                : appColors.gray300,
                        width: 2.w,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.secondTabText,
                    textAlign: TextAlign.center,
                    style: widget.appFonts.textSmMedium.copyWith(
                      color:
                          selectedTabIndex == 1
                              ? appColors.blue500
                              : appColors.textSecondary,
                      fontSize: 16.sp,
                      fontWeight:
                          selectedTabIndex == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        Flexible(
          child: IndexedStack(
            index: selectedTabIndex,
            children: [widget.firstTabContent, widget.secondTabContent],
          ),
        ),
      ],
    );
  }
}
