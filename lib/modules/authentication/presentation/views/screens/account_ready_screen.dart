import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';

class AccountReadyScreen extends StatelessWidget {
  const AccountReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      showFirstImage: false,
      showBottomSvg: false,
      body: Stack(
        children: [
          // Bottom Wavy Background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 350.h,
            child: CustomPaint(
              painter: WavyBackgroundPainter(
                redColor: const Color(0xFFD54141),
                orangeColor: const Color(0xFFF2994A),
                lightOrangeColor: const Color(0xFFEDB17A),
              ),
            ),
          ),

          // Clipped Driver Image with 15px border
          Positioned(
            top: 321.h,
            left: -73.w,
            width: 351.w,
            height: 350.h,
            child: Stack(
              children: [
                // White Border (Clipped slightly larger or drawn with stroke)
                ClipPath(
                  clipper: CloudClipper(),
                  child: Container(color: Colors.white),
                ),
                // The Image (Clipped with a slightly smaller path)
                Padding(
                  padding: EdgeInsets.all(15.w), // 15px border-width from Figma
                  child: ClipPath(
                    clipper: CloudClipper(),
                    child: Image.asset(
                      'assets/account_ready.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content at the top
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your account is ready!',
                  style: appFonts.heading1Bold.copyWith(
                    fontSize: 28.sp,
                    color: appColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Let’s ride now.',
                  style: appFonts.heading1Bold.copyWith(
                    fontSize: 28.sp,
                    color: appColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 32.h),
                RideNowButton(
                  title: 'Find your first ride',
                  onTap: () {
                    context.goNamed(RouteConstants.ride);
                  },
                  width: 200.w,
                  height: 54.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // A more "wavy/cloudy" shape to match the "cut edges" UI
    path.moveTo(w * 0.3, h * 0.9);
    path.quadraticBezierTo(w * 0.1, h * 0.95, w * 0.05, h * 0.8);
    path.quadraticBezierTo(w * -0.05, h * 0.65, w * 0.05, h * 0.5);
    path.quadraticBezierTo(w * 0.0, h * 0.3, w * 0.15, h * 0.2);
    path.quadraticBezierTo(w * 0.3, h * 0.05, w * 0.5, h * 0.15);
    path.quadraticBezierTo(w * 0.7, h * 0.05, w * 0.85, h * 0.2);
    path.quadraticBezierTo(w * 1.0, h * 0.3, w * 0.95, h * 0.5);
    path.quadraticBezierTo(w * 1.05, h * 0.65, w * 0.95, h * 0.8);
    path.quadraticBezierTo(w * 0.9, h * 0.95, w * 0.7, h * 0.9);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WavyBackgroundPainter extends CustomPainter {
  final Color redColor;
  final Color orangeColor;
  final Color lightOrangeColor;

  WavyBackgroundPainter({
    required this.redColor,
    required this.orangeColor,
    required this.lightOrangeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Red Layer (Bottom-most)
    final redPaint = Paint()..color = redColor;
    final redPath = Path();
    redPath.moveTo(0, h * 0.6);
    redPath.quadraticBezierTo(w * 0.25, h * 0.4, w * 0.5, h * 0.7);
    redPath.quadraticBezierTo(w * 0.75, h * 1.0, w, h * 0.8);
    redPath.lineTo(w, h);
    redPath.lineTo(0, h);
    redPath.close();
    canvas.drawPath(redPath, redPaint);

    // Orange Layer (Middle)
    final orangePaint = Paint()..color = orangeColor;
    final orangePath = Path();
    orangePath.moveTo(0, h * 0.45);
    orangePath.quadraticBezierTo(w * 0.3, h * 0.2, w * 0.6, h * 0.5);
    orangePath.quadraticBezierTo(w * 0.85, h * 0.8, w, h * 0.6);
    orangePath.lineTo(w, h);
    orangePath.lineTo(0, h);
    orangePath.close();
    canvas.drawPath(orangePath, orangePaint);

    // Light Orange Layer (Top-most)
    final lightOrangePaint = Paint()..color = lightOrangeColor;
    final lightOrangePath = Path();
    lightOrangePath.moveTo(0, h * 0.3);
    lightOrangePath.quadraticBezierTo(w * 0.2, h * 0.1, w * 0.5, h * 0.4);
    lightOrangePath.quadraticBezierTo(w * 0.8, h * 0.7, w, h * 0.5);
    lightOrangePath.lineTo(w, h);
    lightOrangePath.lineTo(0, h);
    lightOrangePath.close();
    canvas.drawPath(lightOrangePath, lightOrangePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
