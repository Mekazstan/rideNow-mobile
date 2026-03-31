import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';

import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class DriverVerificationPortalScreen extends StatefulWidget {
  const DriverVerificationPortalScreen({super.key});

  @override
  State<DriverVerificationPortalScreen> createState() => _DriverVerificationPortalScreenState();
}

class _DriverVerificationPortalScreenState extends State<DriverVerificationPortalScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadDriverDocuments();
    });
  }

  Future<void> _handleReupload(String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (image == null) return;

      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      ToastService.showInfo('Uploading $documentType...');
      
      await authProvider.uploadDriverDocument(
        documentType: documentType,
        documentUrl: 'reupload_${documentType}',
        documentImageBase64: base64Image,
      );

      ToastService.showSuccess('Document re-uploaded successfully');
      
      // Auto-refresh to show "Awaiting Review"
      if (mounted) {
        authProvider.loadDriverDocuments();
      }
    } catch (e) {
      ToastService.showError('Re-upload failed: $e');
    }
  }

  String _mapBackendDocTypeToName(String type) {
    switch (type) {
      case 'drivers_license':
        return "Driver's License";
      case 'vehicle_registration':
        return 'Vehicle Registration';
      case 'insurance':
        return 'Insurance Certificate';
      case 'car_image':
        return 'Car Image';
      case 'roadworthiness':
        return 'Roadworthiness';
      default:
        return type.replaceAll('_', ' ').capitalize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final authProvider = context.watch<AuthProvider>();
    
    final documents = authProvider.driverDocuments;
    final isLoading = authProvider.isDocumentsLoading;
    final isActionRequired = documents.any((doc) => doc['status'] == 'rejected');

    return RidenowScaffold(
      showAppBar: true,
      appBarTitle: 'Verification Portal',
      showFirstImage: false,
      showBottomImage: false,
      body: RefreshIndicator(
        onRefresh: () => authProvider.loadDriverDocuments(),
        color: appColors.blue600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallStatusCard(appColors, appFonts, isActionRequired),
                    SizedBox(height: 24.h),
                    Text(
                      'Your Documents',
                      style: appFonts.textBaseBold.copyWith(color: appColors.textPrimary),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
              if (isLoading)
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: appColors.blue600)),
                )
              else if (documents.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64.sp, color: appColors.gray300),
                        SizedBox(height: 16.h),
                        Text(
                          'No verification documents found',
                          style: appFonts.textMdBold.copyWith(color: appColors.textPrimary),
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            'Your submitted documents will appear here once they are processed by our admin team.',
                            textAlign: TextAlign.center,
                            style: appFonts.textSmMedium.copyWith(color: appColors.gray500),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = documents[index];
                      return _buildDocumentTile(doc, appColors, appFonts);
                    },
                    childCount: documents.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStatusCard(AppColorExtension appColors, AppFontThemeExtension appFonts, bool isActionRequired) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isActionRequired ? appColors.red400 : appColors.blue600,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Status',
            style: appFonts.textSmMedium.copyWith(color: appColors.textWhite.withOpacity(0.8)),
          ),
          SizedBox(height: 4.h),
          Text(
            isActionRequired ? 'Action Required' : 'Under Review',
            style: appFonts.heading1Bold.copyWith(color: appColors.textWhite, fontSize: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            isActionRequired 
                ? 'Some of your documents were rejected. Please review the comments and re-upload.'
                : 'All documents are submitted and under review. We\'ll notify you once verified.',
            style: appFonts.textXsMedium.copyWith(color: appColors.textWhite.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(Map<String, dynamic> doc, AppColorExtension appColors, AppFontThemeExtension appFonts) {
    final status = doc['status'] as String;
    final comment = doc['adminComment'] as String? ?? doc['rejectionReason'] as String?;
    final docType = doc['documentType'] as String;
    final docName = _mapBackendDocTypeToName(docType);

    Color statusColor;
    IconData statusIcon;
    String statusDisplay;

    switch (status) {
      case 'verified':
        statusColor = appColors.green400;
        statusIcon = Icons.check_circle;
        statusDisplay = 'Verified';
        break;
      case 'rejected':
        statusColor = appColors.red400;
        statusIcon = Icons.error;
        statusDisplay = 'Rejected';
        break;
      case 'uploaded':
        statusColor = appColors.orange400;
        statusIcon = Icons.hourglass_empty;
        statusDisplay = 'Awaiting Review';
        break;
      case 'pending_review':
        statusColor = appColors.orange400;
        statusIcon = Icons.hourglass_top;
        statusDisplay = 'Under Review';
        break;
      default:
        statusColor = appColors.gray400;
        statusIcon = Icons.help_outline;
        statusDisplay = status.capitalize();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.textWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  docName,
                  style: appFonts.textBaseMedium.copyWith(color: appColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      statusDisplay,
                      style: appFonts.textXsMedium.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment != null && status == 'rejected') ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: appColors.red400.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: appColors.red400.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Comment:',
                    style: appFonts.textXsBold.copyWith(color: appColors.red400),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    comment,
                    style: appFonts.textXsMedium.copyWith(color: appColors.textPrimary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => _handleReupload(docType),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.blue600,
                foregroundColor: appColors.textWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                minimumSize: Size(double.infinity, 36.h),
              ),
              child: const Text('Re-upload Document'),
            ),
          ],
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
