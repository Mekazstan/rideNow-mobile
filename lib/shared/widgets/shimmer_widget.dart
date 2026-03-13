import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops:
                  [
                    _animation.value - 0.3,
                    _animation.value,
                    _animation.value + 0.3,
                  ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Basic rectangular shimmer placeholder
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      baseColor: baseColor ?? const Color(0xFFE0E0E0),
      highlightColor: highlightColor ?? const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for wallet balance card
class WalletBalanceShimmer extends StatelessWidget {
  const WalletBalanceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135.h,
      width: 348.w,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShimmerBox(width: 120.w, height: 12.h, borderRadius: 4.r),
            SizedBox(height: 8.h),
            ShimmerBox(width: 180.w, height: 28.h, borderRadius: 4.r),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 146.w, height: 41.h, borderRadius: 8.r),
                ShimmerBox(width: 146.w, height: 41.h, borderRadius: 8.r),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for single transaction item
class TransactionItemShimmer extends StatelessWidget {
  const TransactionItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 65.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 150.w, height: 14.h, borderRadius: 4.r),
                ShimmerBox(width: 60.w, height: 18.h, borderRadius: 12.r),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4.r),
                ShimmerBox(width: 80.w, height: 16.h, borderRadius: 4.r),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for transaction list
class TransactionsListShimmer extends StatelessWidget {
  final int itemCount;

  const TransactionsListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) ...[
              Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
                child: ShimmerBox(
                  width: 100.w,
                  height: 16.h,
                  borderRadius: 4.r,
                ),
              ),
            ],
            const TransactionItemShimmer(),
          ],
        );
      },
    );
  }
}

/// Generic list shimmer with customizable items
class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;
  final Widget Function(int index)? customItemBuilder;

  const ListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
    this.customItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        if (customItemBuilder != null) {
          return customItemBuilder!(index);
        }
        return ShimmerBox(
          width: double.infinity,
          height: itemHeight,
          borderRadius: 8.r,
        );
      },
    );
  }
}

/// Card-style shimmer with multiple lines
class CardShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final List<ShimmerLine> lines;

  const CardShimmer({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.lines = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            lines.map((line) {
              return Padding(
                padding: EdgeInsets.only(bottom: line.spacing),
                child: ShimmerBox(
                  width: line.width,
                  height: line.height,
                  borderRadius: line.borderRadius,
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// Configuration model for CardShimmer lines
class ShimmerLine {
  final double? width;
  final double height;
  final double spacing;
  final double borderRadius;

  const ShimmerLine({
    this.width,
    this.height = 12,
    this.spacing = 8,
    this.borderRadius = 4,
  });
}

/// Grid layout shimmer placeholder
class GridShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const GridShimmer({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerBox(borderRadius: 8);
      },
    );
  }
}

/// Circular avatar shimmer placeholder
class AvatarShimmer extends StatelessWidget {
  final double size;

  const AvatarShimmer({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Multi-line text shimmer placeholder
class TextShimmer extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double lineSpacing;
  final double? lastLineWidth;

  const TextShimmer({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.lineSpacing = 8,
    this.lastLineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLastLine ? 0 : lineSpacing),
          child: ShimmerBox(
            width:
                isLastLine && lastLineWidth != null
                    ? lastLineWidth
                    : double.infinity,
            height: lineHeight,
            borderRadius: 4,
          ),
        );
      }),
    );
  }
}

/// Button-style shimmer placeholder
class ButtonShimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ButtonShimmer({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width ?? double.infinity,
      height: height,
      borderRadius: borderRadius,
    );
  }
}
