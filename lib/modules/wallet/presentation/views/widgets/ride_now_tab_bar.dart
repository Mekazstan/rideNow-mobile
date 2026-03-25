import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RideNowTabBar extends StatefulWidget {
  const RideNowTabBar({
    super.key,
    required this.tabs,
    required this.tabContents,
    required this.appFonts,
    required this.appColors,
    this.initialTabIndex = 0,
  }) : assert(tabs.length == tabContents.length);

  final List<String> tabs;
  final List<Widget> tabContents;
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
    return Column(
      children: [
        Row(
          children: List.generate(
            widget.tabs.length,
            (index) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTabIndex = index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selectedTabIndex == index
                            ? widget.appColors.blue500
                            : widget.appColors.gray300,
                        width: 2.w,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.tabs[index],
                    textAlign: TextAlign.center,
                    style: widget.appFonts.textSmMedium.copyWith(
                      color: selectedTabIndex == index
                          ? widget.appColors.blue500
                          : widget.appColors.textSecondary,
                      fontSize: 16.sp,
                      fontWeight: selectedTabIndex == index
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: IndexedStack(
            index: selectedTabIndex,
            children: widget.tabContents,
          ),
        ),
      ],
    );
  }
}
