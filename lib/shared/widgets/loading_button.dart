import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

/// A button that shows a circular progress indicator when loading
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loadingColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.loadingColor,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
    this.icon,
    this.isOutlined = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final bgColor = backgroundColor ?? appColors.blue600;
    final txtColor = textColor ?? Colors.white;
    final loadColor = loadingColor ?? Colors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : bgColor,
          foregroundColor: txtColor,
          disabledBackgroundColor:
              isOutlined ? Colors.transparent : bgColor.withOpacity(0.7),
          elevation: isOutlined ? 0 : 2,
          shadowColor:
              isOutlined ? Colors.transparent : Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
            side:
                isOutlined
                    ? BorderSide(color: bgColor, width: 1.5)
                    : BorderSide.none,
          ),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(loadColor),
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20.sp,
                        color: isOutlined ? bgColor : txtColor,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      text,
                      style: appFonts.textBaseMedium.copyWith(
                        color: isOutlined ? bgColor : txtColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

/// A compact icon button with loading state
class LoadingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? loadingColor;
  final double size;
  final double iconSize;

  const LoadingIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
    this.loadingColor,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    final bgColor = backgroundColor ?? appColors.blue600;
    final icColor = iconColor ?? Colors.white;
    final loadColor = loadingColor ?? Colors.white;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: isLoading ? bgColor.withOpacity(0.7) : bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child:
              isLoading
                  ? SizedBox(
                    width: iconSize.w * 0.8,
                    height: iconSize.w * 0.8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(loadColor),
                    ),
                  )
                  : Icon(icon, size: iconSize.sp, color: icColor),
        ),
      ),
    );
  }
}

/// A text button with loading state
class LoadingTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? textColor;
  final Color? loadingColor;
  final double fontSize;

  const LoadingTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.loadingColor,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final txtColor = textColor ?? appColors.blue600;
    final loadColor = loadingColor ?? appColors.blue600;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(loadColor),
                ),
              )
              : Text(
                text,
                style: appFonts.textSmMedium.copyWith(
                  color: txtColor,
                  fontSize: fontSize.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }
}
