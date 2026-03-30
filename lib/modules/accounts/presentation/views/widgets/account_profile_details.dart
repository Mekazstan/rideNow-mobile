import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class AccountProfileDetails extends StatefulWidget {
  const AccountProfileDetails({
    super.key,
    required this.appColors,
    required this.appFonts,
  });

  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  @override
  State<AccountProfileDetails> createState() => _AccountProfileDetailsState();
}

class _AccountProfileDetailsState extends State<AccountProfileDetails> {
  final ImagePicker _picker = ImagePicker();

  /// Shows bottom sheet to choose between camera or gallery
  Future<void> _showImageSourceDialog() async {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose Photo Source',
                    style: widget.appFonts.textSmMedium.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    leading: Icon(
                      Icons.photo_camera,
                      color: widget.appColors.gray300,
                    ),
                    title: Text('Camera', style: widget.appFonts.textSmMedium),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: widget.appColors.gray300,
                    ),
                    title: Text('Gallery', style: widget.appFonts.textSmMedium),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Picks an image from the specified source and shows upload confirmation
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        _showUploadConfirmation(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
      if (mounted) {
        ToastService.showError('Failed to pick image: ${e.toString()}');
      }
      }
    }
  }

  /// Shows confirmation dialog with image preview before uploading
  void _showUploadConfirmation(File imageFile) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Upload Photo',
              style: widget.appFonts.textSmMedium.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    imageFile,
                    width: 200.w,
                    height: 200.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Do you want to upload this photo as your profile picture?',
                  style: widget.appFonts.textSmMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: widget.appFonts.textSmMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _uploadPhoto(imageFile);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.appColors.gray300,
                ),
                child: Text(
                  'Upload',
                  style: widget.appFonts.textSmMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Uploads the selected photo to the server
  Future<void> _uploadPhoto(File imageFile) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.uploadProfilePhoto(imageFile);

    if (mounted) {
      if (success) {
        ToastService.showSuccess('Profile photo uploaded successfully!');
      } else {
        ToastService.showError(
          authProvider.errorMessage ??
              'Failed to upload photo. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isUploading = authProvider.isUploadingPhoto;

        return Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    height: 80.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: widget.appColors.textPrimary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child:
                        isUploading
                            ? Center(child: AvatarShimmer(size: 80.w))
                            : user?.profilePhoto != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                user!.profilePhoto!,
                                height: 80.h,
                                width: 80.w,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return AvatarShimmer(size: 80.w);
                                },
                                errorBuilder:
                                    (_, __, ___) => Icon(
                                      Icons.person,
                                      size: 80.sp,
                                      color: widget.appColors.gray400,
                                    ),
                              ),
                            )
                            : Icon(
                              Icons.person,
                              size: 80.sp,
                              color: widget.appColors.gray400,
                            ),
                  ),

                  // Camera button overlay for photo selection
                  if (!isUploading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          height: 24.h,
                          width: 24.w,
                          decoration: BoxDecoration(
                            color: widget.appColors.gray300,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.w),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10.h),

            // Show upload progress indicator
            if (isUploading)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12.w,
                      height: 12.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Uploading photo...',
                      style: widget.appFonts.textSmMedium.copyWith(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            // Display user name, verification badge, and rating
            Builder(
              builder: (context) {
                final firstName = user?.firstName ?? '';
                final lastName = user?.lastName ?? '';
                final fullName = '$firstName $lastName'.trim();
                final displayName = fullName.isEmpty ? 'Guest User' : fullName;
                final isDriver = user?.userType.toLowerCase() == 'driver';

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: widget.appFonts.textSmMedium.copyWith(
                            color: widget.appColors.textPrimary,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (user?.verificationStatus.toLowerCase() ==
                            'verified') ...[
                          SizedBox(width: 6.w),
                          SvgPicture.asset(
                            'assets/badge.svg',
                            width: 20.w,
                            height: 20.h,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (user?.rating != null || isDriver) ...[
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            user?.rating?.toStringAsFixed(1) ?? '0.0',
                            style: widget.appFonts.textSmMedium.copyWith(
                              color: widget.appColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 4.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: widget.appColors.gray300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          user?.userType.toUpperCase() ?? 'RIDER',
                          style: widget.appFonts.textSmMedium.copyWith(
                            color: widget.appColors.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
