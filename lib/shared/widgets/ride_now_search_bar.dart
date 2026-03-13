// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RideNowSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final FocusNode? focusNode;

  const RideNowSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.height,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.focusNode,
  });

  @override
  State<RideNowSearchBar> createState() => _RideNowSearchBarState();
}

class _RideNowSearchBarState extends State<RideNowSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      height: widget.height ?? 48.h,
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? appColors.gray50,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 24.r),
        border: Border.all(
          color: widget.borderColor ?? appColors.gray200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          widget.prefixIcon ??
              Icon(Icons.search, size: 20.w, color: appColors.gray400),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: appFonts.textSmMedium.copyWith(
                  color: appColors.gray400,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.suffixIcon != null) ...[
            SizedBox(width: 12.w),
            widget.suffixIcon!,
          ],
        ],
      ),
    );
  }
}
