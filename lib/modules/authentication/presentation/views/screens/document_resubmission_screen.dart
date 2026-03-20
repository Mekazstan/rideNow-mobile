import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';

class DocumentResubmissionScreen extends StatefulWidget {
  final String documentType;
  final String documentName;

  const DocumentResubmissionScreen({
    super.key,
    required this.documentType,
    required this.documentName,
  });

  @override
  State<DocumentResubmissionScreen> createState() => _DocumentResubmissionScreenState();
}

class _DocumentResubmissionScreenState extends State<DocumentResubmissionScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _licenseNumberController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ToastService.showError('Failed to pick image');
    }
  }

  Future<void> _handleSubmit() async {
    if (_imageFile == null) {
      ToastService.showWarning('Please select an image first');
      return;
    }

    if (widget.documentType == 'drivers_license' && _licenseNumberController.text.trim().isEmpty) {
      ToastService.showWarning('Please enter your license number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      await authProvider.uploadDriverDocument(
        documentType: widget.documentType,
        documentUrl: 'resubmitted_${widget.documentType}',
        documentNumber: widget.documentType == 'drivers_license' ? _licenseNumberController.text.trim() : null,
        documentImageBase64: base64Image,
      );

      if (mounted) {
        ToastService.showSuccess('Document resubmitted successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      ToastService.showError('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      showFirstImage: false,
      showAppBar: true,
      appBarTitle: "Resubmit Document",
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Updating ${widget.documentName}",
              style: appFonts.textBaseMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: appColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Please upload a clear photo of the document to replace the previous one.",
              style: appFonts.textXsMedium.copyWith(color: appColors.gray500),
            ),
            SizedBox(height: 24.h),
            if (widget.documentType == 'drivers_license') ...[
              RidenowTextfield(
                fieldName: 'License Number',
                hintText: 'Enter your license number',
                controller: _licenseNumberController,
              ),
              SizedBox(height: 20.h),
            ],
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color: appColors.gray50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: appColors.gray200, style: BorderStyle.none),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 48.sp, color: appColors.gray400),
                          SizedBox(height: 12.h),
                          Text(
                            "Tap to select image",
                            style: appFonts.textSmMedium.copyWith(color: appColors.gray500),
                          ),
                        ],
                      ),
              ),
            ),
            if (_imageFile != null) ...[
              SizedBox(height: 12.h),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text("Change Image"),
                ),
              ),
            ],
            SizedBox(height: 32.h),
            RideNowButton(
              title: _isLoading ? 'Submitting...' : 'Submit for Review',
              onTap: _handleSubmit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    super.dispose();
  }
}
