import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

enum RideNowButtonVariant { filled, outlined, ghost }

enum RideNowButtonSize { small, medium }

enum RideNowButtonShape { rounded, pill }

enum RideNowButtonColorSet { primary, danger, accent }

class RideNowButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  final double? width;
  final double? height;
  final RideNowButtonVariant variant;
  final RideNowButtonSize size;
  final RideNowButtonShape shape;
  final RideNowButtonColorSet colorSet;
  final Widget? leadingIcon;

  const RideNowButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.width,
    this.height,
    this.variant = RideNowButtonVariant.filled,
    this.size = RideNowButtonSize.medium,
    this.shape = RideNowButtonShape.rounded,
    this.colorSet = RideNowButtonColorSet.primary,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    Color getBaseColor(AppColorExtension colors) {
      switch (colorSet) {
        case RideNowButtonColorSet.primary:
          return colors.blue700;
        case RideNowButtonColorSet.danger:
          return colors.red500;
        case RideNowButtonColorSet.accent:
          return colors.textSecondary;
      }
    }

    Color getTextColor(AppColorExtension colors) {
      if (variant == RideNowButtonVariant.filled) {
        return colors.textWhite;
      } else if (variant == RideNowButtonVariant.outlined ||
          variant == RideNowButtonVariant.ghost) {
        return getBaseColor(colors);
      }
      return colors.textPrimary;
    }

    Color getBackgroundColor(AppColorExtension colors) {
      if (variant == RideNowButtonVariant.filled) {
        return getBaseColor(colors);
      } else if (variant == RideNowButtonVariant.ghost) {
        return colors.gray100;
      }
      return Colors.transparent;
    }

    Color getBorderColor(AppColorExtension colors) {
      if (variant == RideNowButtonVariant.outlined) {
        return getBaseColor(colors);
      }
      return Colors.transparent;
    }

    EdgeInsets getPadding() {
      final bool hasFixedDimensions = width != null || height != null;

      switch (size) {
        case RideNowButtonSize.small:
          return EdgeInsets.symmetric(
            horizontal: hasFixedDimensions ? 8.w : 16.w,
            vertical: hasFixedDimensions ? 4.h : 8.h,
          );
        case RideNowButtonSize.medium:
          return EdgeInsets.symmetric(
            horizontal: hasFixedDimensions ? 12.w : 24.w,
            vertical: hasFixedDimensions ? 8.h : 14.h,
          );
      }
    }

    BorderSide getBorderSide(AppColorExtension colors) {
      return BorderSide(color: getBorderColor(colors), width: 1.0);
    }

    OutlinedBorder getShape() {
      return RoundedRectangleBorder(
        borderRadius:
            shape == RideNowButtonShape.pill
                ? BorderRadius.circular(100)
                : BorderRadius.circular(8),
      );
    }

    Widget buttonChild =
        isLoading
            ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: getTextColor(appColors),
                strokeWidth: 2,
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appFonts.textMdBold.copyWith(
                      color: getTextColor(appColors),
                    ),
                  ),
                ),
              ],
            );

    ButtonStyle? style;
    if (variant == RideNowButtonVariant.filled) {
      style = ElevatedButton.styleFrom(
        backgroundColor: getBackgroundColor(appColors),
        foregroundColor: getTextColor(appColors),
        textStyle: appFonts.textMdBold,
        shape: getShape(),
        padding: getPadding(),
        elevation: 0,
        disabledBackgroundColor: appColors.inactiveButton,
        disabledForegroundColor: appColors.textTertiary,
      );
    } else if (variant == RideNowButtonVariant.outlined) {
      style = OutlinedButton.styleFrom(
        foregroundColor: getTextColor(appColors),
        textStyle: appFonts.textMdBold,
        side: getBorderSide(appColors),
        shape: getShape(),
        padding: getPadding(),
        disabledForegroundColor: appColors.textTertiary,
      );
    } else if (variant == RideNowButtonVariant.ghost) {
      style = TextButton.styleFrom(
        backgroundColor: getBackgroundColor(appColors),
        foregroundColor: getTextColor(appColors),
        textStyle: appFonts.textMdBold,
        shape: getShape(),
        padding: getPadding(),
        disabledForegroundColor: appColors.textTertiary,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child:
          variant == RideNowButtonVariant.filled
              ? ElevatedButton(
                onPressed: isLoading ? null : onTap,
                style: style,
                child: buttonChild,
              )
              : variant == RideNowButtonVariant.outlined
              ? OutlinedButton(
                onPressed: isLoading ? null : onTap,
                style: style,
                child: buttonChild,
              )
              : TextButton(
                onPressed: isLoading ? null : onTap,
                style: style,
                child: buttonChild,
              ),
    );
  }
}
