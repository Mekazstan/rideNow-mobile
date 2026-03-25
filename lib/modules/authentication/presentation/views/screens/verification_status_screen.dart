import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/modules/ride/data/models/driver_misc_models.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/screens/document_resubmission_screen.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().fetchVerificationStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final viewModel = context.watch<DriverProvider>();

    return RidenowScaffold(
      showFirstImage: false,
      showAppBar: true,
      appBarTitle: "Verification Center",
      body: viewModel.isLoading && viewModel.verificationStatus == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => viewModel.fetchVerificationStatus(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallStatusCard(viewModel, appColors, appFonts),
                    SizedBox(height: 24.h),
                    Text(
                      "Documents",
                      style: appFonts.textBaseMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: appColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (viewModel.verificationStatus?.documents.isEmpty ?? true)
                      _buildNoDocumentsState(appColors, appFonts)
                    else
                      ...viewModel.verificationStatus!.documents.map(
                        (doc) => _buildDocumentTile(doc, appColors, appFonts),
                      ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverallStatusCard(
    DriverProvider viewModel,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    final status = viewModel.verificationStatus;
    final isFullyVerified = status?.isFullyVerified ?? false;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isFullyVerified ? appColors.green50 : appColors.blue50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isFullyVerified ? appColors.green200 : appColors.blue200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isFullyVerified ? Icons.verified : Icons.info_outline,
                color: isFullyVerified ? appColors.green600 : appColors.blue600,
                size: 32.sp,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFullyVerified ? "Account Verified" : "Verification Pending",
                      style: appFonts.textBaseMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isFullyVerified ? appColors.green800 : appColors.blue800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      status?.message ?? "We are currently reviewing your profile.",
                      style: appFonts.textXsMedium.copyWith(
                        color: isFullyVerified ? appColors.green700 : appColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isFullyVerified) ...[
            SizedBox(height: 20.h),
            _buildMiniStatusRow("Approval", status?.approvalStatus ?? "pending", appColors, appFonts),
            SizedBox(height: 8.h),
            _buildMiniStatusRow("Background Check", status?.backgroundCheckStatus ?? "pending", appColors, appFonts),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStatusRow(String label, String status, AppColorExtension appColors, AppFontThemeExtension appFonts) {
    Color statusColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'passed':
        statusColor = appColors.green600;
        icon = Icons.check_circle;
        break;
      case 'rejected':
      case 'failed':
        statusColor = appColors.red600;
        icon = Icons.cancel;
        break;
      default:
        statusColor = appColors.gray500;
        icon = Icons.access_time;
    }

    return Row(
      children: [
        Text(
          label,
          style: appFonts.textXsMedium.copyWith(color: appColors.gray600),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: statusColor),
            SizedBox(width: 4.w),
            Text(
              status.toUpperCase(),
              style: appFonts.textXsMedium.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentTile(
    DriverDocumentDetail doc,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    final isRejected = doc.status == 'rejected';
    final isVerified = doc.status == 'verified';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDocIcon(doc.documentType, appColors),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.documentName ?? _formatDocType(doc.documentType),
                      style: appFonts.textSmMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: appColors.textPrimary,
                      ),
                    ),
                    Text(
                      "Submitted on ${_formatDate(doc.createdAt)}",
                      style: appFonts.textXsMedium.copyWith(color: appColors.gray500),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(doc.status, appColors, appFonts),
            ],
          ),
          if (isRejected && (doc.rejectionReason != null || doc.adminComment != null)) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: appColors.red50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Feedback:",
                    style: appFonts.textXsMedium.copyWith(
                      color: appColors.red700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    doc.adminComment ?? doc.rejectionReason ?? "No specific reason provided.",
                    style: appFonts.textXsMedium.copyWith(color: appColors.red600),
                  ),
                ],
              ),
            ),
          ],
          if (isRejected) ...[
            SizedBox(height: 16.h),
            RideNowButton(
              title: "Resubmit Document",
              onTap: () => _handleResubmit(doc),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocIcon(String type, AppColorExtension appColors) {
    IconData iconData;
    switch (type) {
      case 'drivers_license':
        iconData = Icons.badge;
        break;
      case 'vehicle_registration':
        iconData = Icons.description;
        break;
      case 'insurance':
        iconData = Icons.security;
        break;
      case 'roadworthiness':
        iconData = Icons.build_circle;
        break;
      default:
        iconData = Icons.file_present;
    }
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: appColors.gray100,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: appColors.gray600, size: 20.sp),
    );
  }

  Widget _buildStatusBadge(String status, AppColorExtension appColors, AppFontThemeExtension appFonts) {
    Color bgColor;
    Color textColor;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'verified':
        bgColor = appColors.green100;
        textColor = appColors.green700;
        break;
      case 'rejected':
        bgColor = appColors.red100;
        textColor = appColors.red700;
        break;
      case 'pending':
      case 'pending_review':
        bgColor = appColors.orange100;
        textColor = appColors.orange700;
        label = "PENDING";
        break;
      default:
        bgColor = appColors.gray100;
        textColor = appColors.gray700;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: appFonts.textXsMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  String _formatDocType(String type) {
    return type.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildNoDocumentsState(AppColorExtension appColors, AppFontThemeExtension appFonts) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: appColors.gray50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 48.sp, color: appColors.gray300),
          SizedBox(height: 12.h),
          Text(
            "No documents found",
            style: appFonts.textSmMedium.copyWith(color: appColors.gray500),
          ),
        ],
      ),
    );
  }

  void _handleResubmit(DriverDocumentDetail doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentResubmissionScreen(
          documentType: doc.documentType,
          documentName: doc.documentName ?? _formatDocType(doc.documentType),
        ),
      ),
    ).then((_) {
      // Refresh status when returning
      context.read<DriverProvider>().fetchVerificationStatus();
    });
  }
}
