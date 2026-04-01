import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    // In a real app, we would call a provider method here
    // For now we'll simulate a delay and reset the ride
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      context.read<RideProvider>().reset();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final provider = context.watch<RideProvider>();
    final driver = provider.rideDetails?.driver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              provider.reset();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'Skip',
              style: appFonts.textSmRegular.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              'How was your trip?',
              style: appFonts.heading2Bold,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Your feedback will help us improve the experience for everyone.',
              style: appFonts.textSmRegular.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.h),
            
            // Driver Profile
            CircleAvatar(
              radius: 50.r,
              backgroundImage: (driver?.profileImage != null && driver!.profileImage!.isNotEmpty)
                  ? NetworkImage(driver.profileImage!) as ImageProvider
                  : const AssetImage('assets/images/user_placeholder.png'),
            ),
            SizedBox(height: 16.h),
            Text(
              driver?.name ?? 'Driver Name',
              style: appFonts.textBaseBold,
            ),
            Text(
              'Driver',
              style: appFonts.textSmRegular.copyWith(color: Colors.grey),
            ),
            
            SizedBox(height: 40.h),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 48.sp,
                      color: index < _rating ? Colors.amber : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                );
              }),
            ),
            
            SizedBox(height: 40.h),
            
            // Feedback Text Field
            RidenowTextfield(
              fieldName: 'Feedback',
              showFieldName: false,
              controller: _feedbackController,
              hintText: 'Add a comment (optional)',
              maxLines: 4,
            ),
            
            SizedBox(height: 48.h),
            
            // Submit Button
            RideNowButton(
              title: 'Submit Feedback',
              isLoading: _isSubmitting,
              onTap: _handleSubmit,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
