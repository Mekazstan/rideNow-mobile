// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ridenowappsss/core/utils/theme/app_colors.dart';
import 'package:ridenowappsss/core/utils/theme/custom_text_styles.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_request_model.dart';

class WaitingForDriverSheet extends StatelessWidget {
  final RideDetails? rideDetails;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  const WaitingForDriverSheet({
    super.key,
    required this.rideDetails,
    required this.onCall,
    required this.onChat,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final driverName = rideDetails?.driver?.name ?? 'Driver';
    final vehicleInfo = rideDetails?.vehicle?.model ?? 'Vehicle';
    final plateNumber = rideDetails?.vehicle?.plateNumber ?? '...';
    final rating = rideDetails?.driver?.rating ?? 4.9;
    final estimatedTime = '5 mins';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$estimatedTime away',
                style: CustomTextStyles.headerMedium.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                'Arrives at 12:45 PM', // Mock
                style: CustomTextStyles.bodyMedium.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$driverName is on the way!', style: CustomTextStyles.bodyLarge),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    rideDetails?.driver?.profileImage != null
                        ? NetworkImage(rideDetails!.driver!.profileImage!)
                        : null,
                onBackgroundImageError: rideDetails?.driver?.profileImage != null 
                    ? (exception, stackTrace) {} 
                    : null,
                child:
                    rideDetails?.driver?.profileImage == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driverName, style: CustomTextStyles.headerSmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('$rating', style: CustomTextStyles.bodySmall),
                        const SizedBox(width: 8),
                        Text(
                          '$vehicleInfo • $plateNumber',
                          style: CustomTextStyles.bodySmall.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: IconButton(
                      icon: const Icon(
                        Icons.call,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: onCall,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chat_bubble,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: onChat,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onCancel,
              child: Text(
                'Cancel Ride',
                style: CustomTextStyles.bodyMedium.copyWith(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
