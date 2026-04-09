import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/step_indicator.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';

class DriverDocumentCollectionScreen extends StatefulWidget {
  const DriverDocumentCollectionScreen({super.key});

  @override
  State<DriverDocumentCollectionScreen> createState() =>
      _DriverDocumentCollectionScreenState();
}

class _DriverDocumentCollectionScreenState
    extends State<DriverDocumentCollectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _licenseNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  final Map<String, File?> _documents = {
    'License': null,
    'Registration': null,
    'Insurance': null,
    'Roadworthiness': null,
    // 'CarImage': null,
  };

  final Map<String, String> _documentLabels = {
    'License': "Driver's License",
    'Registration': 'Vehicle Registration (Yellow Paper)',
    'Insurance': 'Insurance Certificate',
    'Roadworthiness': 'Roadworthiness Certificate',
    // 'CarImage': 'Front View of Car',
  };

  Future<void> _pickImage(String docKey) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _documents[docKey] = File(image.path);
        });
      }
    } catch (e) {
      ToastService.showError('Failed to pick image');
    }
  }

  Future<void> _handleSubmit() async {
    // Check if all documents except Insurance are uploaded
    final requiredKeys = ['License', 'Registration', 'Roadworthiness'];
    if (requiredKeys.any((key) => _documents[key] == null)) {
      ToastService.showWarning('Please upload all required documents');
      return;
    }

    if (_documents['License'] != null && _licenseNumberController.text.trim().isEmpty) {
      ToastService.showWarning('Please enter your Driver\'s License Number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user == null) {
        ToastService.showError('User session not found. Please log in again.');
        return;
      }

      // Collect documents for batch upload
      final List<Map<String, dynamic>> documentsToUpload = [];
      
      // We will perform encoding in parallel for better performance
      final List<Future<Map<String, dynamic>?>> encodingFutures = [];

      for (var entry in _documents.entries) {
        final key = entry.key;
        final file = entry.value;

        if (file == null) continue;

        encodingFutures.add(() async {
          // Map UI key to backend DocumentType enum
          String docType;
          switch (key) {
            case 'License':
              docType = 'drivers_license';
              break;
            case 'Registration':
              docType = 'vehicle_registration';
              break;
            case 'Insurance':
              docType = 'insurance';
              break;
            case 'Roadworthiness':
              docType = 'roadworthiness';
              break;
            // case 'CarImage':
            //   docType = 'car_image';
            //   break;
            default:
              docType = 'other';
          }

          final bytes = await file.readAsBytes();
          final base64Image = base64Encode(bytes);
          final documentLabel = _documentLabels[key] ?? key;

          return {
            'documentType': docType,
            'documentName': documentLabel, // This is what the user requested: exact names
            'documentUrl': 'uploaded_via_onboarding_${docType}',
            'documentNumber': docType == 'drivers_license' ? _licenseNumberController.text.trim() : null,
            'documentImageBase64': base64Image,
          };
        }());
      }

      // Wait for all encodings to finish
      final results = await Future.wait(encodingFutures);
      for (var result in results) {
        if (result != null) documentsToUpload.add(result);
      }

      if (kDebugMode) {
        print('=== Batch Uploading ${documentsToUpload.length} Documents ===');
      }

      // Send as a single batch request
      final response = await authProvider.batchUploadDriverDocuments(
        documents: documentsToUpload,
      );
      
      if (kDebugMode) {
        print('Batch upload response: $response');
      }

      if (mounted) {
        final nextStep = response?['next_step'] as String?;
        ToastService.showSuccess('Documents submitted for verification');
        
        if (nextStep == 'payment_plan') {
          context.goNamed(RouteConstants.selectPaymentPlan);
        } else {
          // Fallback or move to dashboard if already completed
          context.goNamed(RouteConstants.dashboard);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Upload error: $e');
      ToastService.showError('Upload failed. $e');
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 58.h),
              const StepIndicator(
                currentStep: 3,
                totalSteps: 5,
                stepLabels: ["", "", "Document Collection", "", ""],
                showStepLabels: [false, false, true, false, false],
              ),
              SizedBox(height: 13.h),
              Text(
                "Verify your identity",
                style: appFonts.heading1Bold.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  color: appColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Upload clear photos of your documents to help us verify your account faster.",
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.gray500,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Card(
                elevation: 0,
                color: appColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ..._documents.keys.map(
                        (key) => _buildUploadCard(key, appColors, appFonts),
                      ),
                      SizedBox(height: 24.h),
                      _buildSubmitButton(appColors, appFonts),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard(String key, AppColorExtension appColors, AppFontThemeExtension appFonts) {
    final file = _documents[key];
    final isOptional = key == 'Insurance';
    final label = isOptional ? "${_documentLabels[key]!} (Optional)" : _documentLabels[key]!;

    return GestureDetector(
      onTap: () => _pickImage(key),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: appColors.textWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: file != null
                ? appColors.green400
                : isOptional
                    ? appColors.gray200
                    : appColors.gray200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  file != null ? Icons.check_circle : Icons.upload_file,
                  color: file != null ? appColors.green400 : appColors.blue600,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: appFonts.textBaseMedium.copyWith(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (file != null)
                  Text(
                    'Change',
                    style: appFonts.textXsMedium.copyWith(color: appColors.blue600),
                  ),
              ],
            ),
            if (file != null) ...[
              SizedBox(height: 12.h),
              if (key == 'License') ...[
                RidenowTextfield(
                  fieldName: 'License Number',
                  hintText: 'Enter your license number',
                  controller: _licenseNumberController,
                ),
                SizedBox(height: 12.h),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  file,
                  height: 120.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppColorExtension appColors, AppFontThemeExtension appFonts) {
    return RideNowButton(
      title: 'Submit for Verification',
      onTap: _handleSubmit,
      isLoading: _isLoading,
    );
  }
  @override
  void dispose() {
    _licenseNumberController.dispose();
    super.dispose();
  }
}
