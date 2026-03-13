// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ridenowappsss/core/utils/theme/app_colors.dart';
import 'package:ridenowappsss/core/utils/theme/custom_text_styles.dart';

class TripArrivedSheet extends StatelessWidget {
  final VoidCallback onRateDriver;
  final VoidCallback onBookAnother;

  const TripArrivedSheet({
    super.key,
    required this.onRateDriver,
    required this.onBookAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 24),
          Text('You have arrived', style: CustomTextStyles.headerLarge),
          const SizedBox(height: 8),
          Text(
            'Hope you enjoyed your ride!',
            style: CustomTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRateDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Rate your driver',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBookAnother,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: AppColors.primaryColor),
              ),
              child: const Text(
                'Book another ride',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
