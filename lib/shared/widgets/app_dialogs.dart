import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/loading_button.dart';

class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onConfirm;

  const AppSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Okay',
    required this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Okay',
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AppSuccessDialog(
            title: title,
            message: message,
            buttonText: buttonText,
            onConfirm: onConfirm,
          ),
    );
  }

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
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 32.sp),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: appFonts.textSmRegular.copyWith(
                color: appColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 32.h),
            LoadingButton(
              text: buttonText,
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              backgroundColor: const Color(0xFF10B981),
              height: 52,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class AppErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onConfirm;

  const AppErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Close',
    this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Close',
    VoidCallback? onConfirm,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return AppErrorDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onConfirm: onConfirm,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

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
              color: appColors.red600.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: appColors.red50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: appColors.red600,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: appFonts.heading1Bold.copyWith(
                color: appColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: appFonts.textSmRegular.copyWith(
                color: appColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: LoadingButton(
                text: buttonText,
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm?.call();
                },
                backgroundColor: appColors.red600,
                height: 52,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class AppLoadingDialog extends StatelessWidget {
  final String message;

  const AppLoadingDialog({
    super.key,
    this.message = 'Please wait...',
  });

  static void show(BuildContext context, {String message = 'Please wait...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppLoadingDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48.w,
              height: 48.w,
              child: CircularProgressIndicator(
                strokeWidth: 3.w,
                valueColor: AlwaysStoppedAnimation<Color>(appColors.brandDefault),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onEnable;

  const LocationPermissionDialog({
    super.key,
    required this.onEnable,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onEnable,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(onEnable: onEnable),
    );
  }

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
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: appColors.blue50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: appColors.blue500,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Enable Location',
              textAlign: TextAlign.center,
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Please enable location sharing to see your current location and find nearby rides instantly.',
              textAlign: TextAlign.center,
              style: appFonts.textSmRegular.copyWith(
                color: appColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 32.h),
            LoadingButton(
              text: 'Enable Location',
              onPressed: () {
                Navigator.pop(context);
                onEnable();
              },
              backgroundColor: appColors.blue500,
              height: 52,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
