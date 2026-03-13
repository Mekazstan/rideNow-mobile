import 'package:flutter/material.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class UserTypeOption extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final String svgImage;

  const UserTypeOption({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.svgImage,
  });

  @override
  State<UserTypeOption> createState() => _UserTypeOptionState();
}

class _UserTypeOptionState extends State<UserTypeOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _titleOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: 56.0, end: 197.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _titleOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(UserTypeOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final backgroundColor = appColors.textWhite;
    final textColor = appColors.textPrimary;
    final borderColor = appColors.gray200;
    final iconColor = widget.isSelected ? appColors.blue600 : appColors.gray400;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child:
                _animationController.value > 0.5
                    ? _buildExpandedLayout(
                      appColors,
                      appFonts,
                      textColor,
                      iconColor,
                    )
                    : _buildCompactLayout(
                      appColors,
                      appFonts,
                      textColor,
                      iconColor,
                    ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedLayout(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    Color textColor,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.radio_button_on,
                color: iconColor,
                key: const ValueKey('selected'),
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 158,
              height: 158,
              child: Image.asset(widget.svgImage, fit: BoxFit.contain),
            ),
          ),
        ),
        FadeTransition(
          opacity: AlwaysStoppedAnimation(1.0 - _titleOpacityAnimation.value),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.title,
                style: appFonts.textBaseMedium.copyWith(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    Color textColor,
    Color iconColor,
  ) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.isSelected ? Icons.radio_button_on : Icons.radio_button_off,
            color: iconColor,
            key: ValueKey(widget.isSelected),
          ),
        ),
        const SizedBox(width: 16.0),
        FadeTransition(
          opacity: _titleOpacityAnimation,
          child: Text(
            widget.title,
            style: appFonts.textBaseMedium.copyWith(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const Spacer(),
        Image.asset(widget.svgImage),
      ],
    );
  }
}
