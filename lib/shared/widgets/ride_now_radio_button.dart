// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class RideNowRadioButton extends StatelessWidget {
  const RideNowRadioButton({
    super.key,
    required this.isSelected,
    this.onTap,
    this.activeColor = const Color(0xFF6366F1),
    this.inactiveColor = const Color(0xFFE5E7EB),
    this.width = 48.0,
    this.height = 24.0,
  });

  final bool isSelected;
  final VoidCallback? onTap;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : inactiveColor,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: isSelected ? activeColor : inactiveColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  isSelected ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: height - 4,
                height: height - 4,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.grey[400],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
