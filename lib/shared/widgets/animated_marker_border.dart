import 'package:flutter/material.dart';

class AnimatedMarkerBorder extends CustomPainter {
  final double progress;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  AnimatedMarkerBorder({
    required this.progress,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rect);

    // Calculate animation progress around the path
    final pathMetrics = path.computeMetrics();
    for (var pathMetric in pathMetrics) {
      final length = pathMetric.length;
      final animatedOffset = (progress * length) % length;
      final extractPath = pathMetric.extractPath(
        animatedOffset,
        animatedOffset + (length * 0.3), // Show 30% of the border at a time
      );

      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(AnimatedMarkerBorder oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class AnimatedBorderWidget extends StatefulWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Duration animationDuration;

  const AnimatedBorderWidget({
    super.key,
    required this.child,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.borderRadius = 20.0,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedBorderWidget> createState() => _AnimatedBorderWidgetState();
}

class _AnimatedBorderWidgetState extends State<AnimatedBorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedMarkerBorder(
            progress: _controller.value,
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}
