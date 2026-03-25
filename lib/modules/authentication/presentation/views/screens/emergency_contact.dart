// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/services/smile_id_service.dart';
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/contact_selection_sheet.dart';
import 'package:ridenowappsss/modules/authentication/domain/services/contact_services.dart' as services;
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/emergency_contact_provider.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_search_bar.dart';
import 'package:ridenowappsss/shared/widgets/step_indicator.dart';
import 'package:ridenowappsss/shared/widgets/app_dialogs.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart'
    as models;

class EmergencyContact extends StatefulWidget {
  const EmergencyContact({super.key});

  @override
  State<EmergencyContact> createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  final TextEditingController _searchController = TextEditingController();
  final services.ContactService _contactService = services.ContactService();
  final SecureStorageService _storageService = SecureStorageService();
  final SmileIDService _smileService = SmileIDService();
  bool _isLoading = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeSmileID();
  }

  /// Initialize Smile ID SDK
  Future<void> _initializeSmileID() async {
    try {
      await _smileService.initialize();
      debugPrint('✅ Smile ID initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Smile ID: $e');
      if (mounted) {
        ToastService.showWarning('Failed to initialize verification service: $e');
      }
    }
  }



  /// Handle Add Contacts button press
  Future<void> _handleAddContactsPressed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final hasPermission = await _contactService.requestContactsPermission();

      if (!hasPermission) {
        _showPermissionDeniedDialog();
        return;
      }

      final deviceContacts = await _contactService.fetchDeviceContacts();

      if (deviceContacts.isEmpty) {
        _showNoContactsDialog();
        return;
      }

      // Release loading spinner before showing the sheet
      if (mounted) setState(() => _isLoading = false);

      await _showContactSelectionSheet(deviceContacts);
    } catch (e) {
      debugPrint('Error adding contacts: $e');
      if (mounted) {
        ToastService.showError('Failed to load contacts: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a bottom-sheet for the user to manually select contacts to add.
  Future<void> _showContactSelectionSheet(
    List<models.EmergencyContact> deviceContacts,
  ) async {
    final provider = Provider.of<EmergencyContactProvider>(
      context,
      listen: false,
    );

    final available = deviceContacts
        .where((c) => !provider.emergencyContacts.any((ec) => ec.id == c.id))
        .toList();

    if (available.isEmpty) {
      ToastService.showInfo('All device contacts are already added');
      return;
    }


    final List<models.EmergencyContact>? selected =
        await showModalBottomSheet<List<models.EmergencyContact>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ContactSelectionSheet(available: available),
    );

    if (selected != null && selected.isNotEmpty) {
      for (final contact in selected) {
        provider.addEmergencyContact(contact);
      }
      if (mounted) {
        ToastService.showSuccess(
          '${selected.length} contact${selected.length > 1 ? "s" : ""} added successfully',
        );
      }
    }
  }

  /// Start Smile ID Verification with Native WebView
  Future<void> _startSmileIDVerification() async {
    if (_isVerifying || !_smileService.isInitialized) {
      debugPrint(
        '⚠️ Cannot start verification: isVerifying=$_isVerifying, isInitialized=${_smileService.isInitialized}',
      );
      return;
    }

    setState(() => _isVerifying = true);
    bool isLoadingDialogShowing = false;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final contactProvider = Provider.of<EmergencyContactProvider>(context, listen: false);
      
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User data not found. Please log in again.');
      }

      // 1. Submit Contacts and Permissions first
      if (mounted) {
        AppLoadingDialog.show(context, message: 'Saving emergency contacts...');
        isLoadingDialogShowing = true;
      }

      final permissions = {'location': true, 'contacts': true};
      final emergencyContacts = contactProvider.emergencyContacts.map((c) => {
        'name': c.name,
        'phone': c.phone,
        'email': (c.email != null && c.email!.trim().isNotEmpty) ? c.email : null,
        'relationship': 'Friend', // Default relationship
        'is_app_user': false,
        'app_user_id': null,
      }).toList();

      final contactsSaved = await authProvider.submitPermissionsAndContacts(
        permissions: permissions,
        emergencyContacts: emergencyContacts,
      );

      if (mounted && isLoadingDialogShowing) {
        Navigator.pop(context);
        isLoadingDialogShowing = false;
      }

      if (!contactsSaved) {
        throw Exception('Failed to save emergency contacts to server.');
      }

      debugPrint('🚀 Starting Smile ID verification for user: ${user.id}');

      // 2. Launch SmartSelfie Enrollment flow
      final result = await _smileService.startSmartSelfieEnrollment(
        context: context,
        userId: user.id,
      );

      // Handle result
      if (result != null) {
        if (result.success) {
          // 3. Post verification result to backend
          if (mounted) {
            AppLoadingDialog.show(context, message: 'Completing verification...');
            isLoadingDialogShowing = true;
          }

          final rawData = result.data is String 
              ? json.decode(result.data as String) as Map<String, dynamic>
              : result.data as Map<String, dynamic>;

          // Remap keys to match backend SmileSessionDataDto
          final smileData = <String, dynamic>{
            'job_id': result.jobId,
            'is_client_side': true,
            'verification_type': 'smart_selfie',
            'selfie_image': rawData['selfieFile'],
            'liveness_images': rawData['livenessFiles'],
          };

          final verificationPosted = await authProvider.completeIdentityVerification(
            smileSessionData: smileData,
          );

          if (mounted && isLoadingDialogShowing) {
            Navigator.pop(context);
            isLoadingDialogShowing = false;
          }

          if (!verificationPosted) {
            throw Exception('Failed to update verification status on server.');
          }

          // Save verification status locally
          await _storageService.setSmileIdVerified(true);
          debugPrint('✅ Verification successful and posted to backend');

          if (mounted) {
            ToastService.showSuccess('Identity verification completed successfully!');
            _navigateToRideScreen();
          }
        } else {
          // Verification failed or was cancelled
          debugPrint('⚠️ Verification failed: ${result.message}');

          if (mounted) {
            _showVerificationFailedDialog(
              message: result.message ?? 'Verification was cancelled or failed',
            );
          }
        }
      } else {
        // Result is null
        debugPrint('⚠️ Verification returned null');
        if (mounted) {
          _showVerificationFailedDialog(
            message: 'Verification process was interrupted',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Verification error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted && isLoadingDialogShowing) {
        Navigator.pop(context);
        isLoadingDialogShowing = false;
      }

      if (mounted) {
        _showVerificationFailedDialog(
          message: 'Process failed: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  /// Navigate to ride screen based on user type
  void _navigateToRideScreen() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final userType = user?.userType.toLowerCase() ?? 'rider';
      final isDriverOnboarding = user?.driverOnboardingStatus == 'in_progress';

      if (userType == 'driver' || isDriverOnboarding) {
        context.goNamed(RouteConstants.letsKnowYouMore);
      } else {
        context.goNamed(RouteConstants.accountReady);
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      context.goNamed(RouteConstants.ride);
    }
  }

  /// Show permission denied dialog
  void _showPermissionDeniedDialog() {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Permission Required', style: appFonts.heading2Bold),
            content: Text(
              'Contacts permission is required to add emergency contacts. Please grant permission in settings.',
              style: appFonts.textMdRegular,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: appFonts.textMdMedium.copyWith(
                    color: appColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _contactService.openAppSettings();
                },
                child: Text(
                  'Open Settings',
                  style: appFonts.textMdMedium.copyWith(
                    color: appColors.blue700,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Show no contacts dialog
  void _showNoContactsDialog() {
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('No Contacts Found', style: appFonts.heading2Bold),
            content: Text(
              'No contacts were found on your device.',
              style: appFonts.textMdRegular,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: appFonts.textMdMedium),
              ),
            ],
          ),
    );
  }

  /// Show verification failed dialog
  void _showVerificationFailedDialog({String? message}) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Verification Status', style: appFonts.heading2Bold),
            content: Text(
              message ??
                  'Identity verification could not be completed. You can continue without verification or try again.',
              style: appFonts.textMdRegular,
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.blue700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _startSmileIDVerification();
                      });
                    },
                    child: Text('Try Again', style: appFonts.textMdMedium),
                  ),
                  SizedBox(height: 8.h),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appColors.textPrimary,
                      side: BorderSide(color: appColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToRideScreen();
                    },
                    child: Text(
                      'Continue Without Verification',
                      style: appFonts.textMdMedium.copyWith(
                        color: appColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ],
          ),
    );
  }

  void _handleSearch(String query, EmergencyContactProvider provider) {
    provider.updateSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 58.h),
            StepIndicator(
              currentStep: 3,
              totalSteps: 4,
              stepLabels: ['', '', 'Add your emergency contacts.', ''],
              showStepLabels: [false, false, true, false],
            ),
            SizedBox(height: 32.h),
            Text(
              'Add your emergency contacts.',
              style: appFonts.heading1Bold.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: appColors.textSecondary,
              ),
            ),
            SizedBox(height: 25.h),
            Row(
              children: [
                SvgPicture.asset('assets/contactLocation.svg'),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Your contacts can watch your ride making it\nsafer for you',
                    style: appFonts.textSmMedium.copyWith(
                      color: appColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Consumer<EmergencyContactProvider>(
              builder: (context, provider, _) {
                return RideNowSearchBar(
                  hintText: 'Search contacts',
                  controller: _searchController,
                  onChanged: (query) => _handleSearch(query, provider),
                );
              },
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: Consumer<EmergencyContactProvider>(
                builder: (context, provider, _) {
                  if (!provider.hasEmergencyContacts) {
                    return _buildEmptyState(appColors, appFonts);
                  }

                  final contacts = provider.filteredEmergencyContacts;

                  if (contacts.isEmpty) {
                    return Center(
                      child: Text(
                        'No contacts match your search',
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _buildContactCard(
                        context,
                        contact,
                        appColors,
                        appFonts,
                        provider,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            Consumer<EmergencyContactProvider>(
              builder: (context, provider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAddContactsButton(appColors, appFonts),
                    SizedBox(height: 3.h),
                    _buildContinueButton(appColors, appFonts, provider.hasEmergencyContacts),
                  ],
                );
              },
            ),
            SizedBox(height: 31.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Finding friends',
            style: appFonts.textSmMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.h),
          Image.asset('assets/groups.png'),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    dynamic contact,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    EmergencyContactProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: appColors.textWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: appColors.textSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: appColors.blue700.withOpacity(0.1),
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: appFonts.textMdBold.copyWith(
                color: appColors.blue700,
                fontSize: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: appFonts.textMdMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  contact.phone,
                  style: appFonts.textSmRegular.copyWith(
                    color: appColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showRemoveDialog(context, contact, provider),
            icon: Icon(Icons.close, color: appColors.red300, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactsButton(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    final isDisabled = _isLoading || _isVerifying;

    return RideNowButton(
      title: 'Add Contacts',
      onTap: _handleAddContactsPressed,
      isLoading: _isLoading,
      leadingIcon: _isLoading
          ? null
          : SvgPicture.asset(
              'assets/add.svg',
              color: appColors.textWhite,
            ),
    );
  }

  Widget _buildContinueButton(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    bool hasContacts,
  ) {
    return RideNowButton(
      title: _isVerifying 
          ? 'Verifying...' 
          : (hasContacts ? 'Continue to Verification' : 'Skip'),
      onTap: _isVerifying ? null : () => _startSmileIDVerification(),
      isLoading: _isVerifying,
      variant: RideNowButtonVariant.ghost,
      colorSet: RideNowButtonColorSet.accent,
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    dynamic contact,
    EmergencyContactProvider provider,
  ) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Remove Contact', style: appFonts.heading2Bold),
            content: Text(
              'Are you sure you want to remove ${contact.name} from emergency contacts?',
              style: appFonts.textMdRegular,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: appFonts.textMdMedium.copyWith(
                    color: appColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  provider.removeEmergencyContact(contact.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ToastService.showInfo('${contact.name} removed');
                  }
                },
                child: Text(
                  'Remove',
                  style: appFonts.textMdMedium.copyWith(
                    color: appColors.red300,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _ContactSelectionSheet extends StatefulWidget {
  const _ContactSelectionSheet({required this.available});

  final List<models.EmergencyContact> available;

  @override
  State<_ContactSelectionSheet> createState() => _ContactSelectionSheetState();
}

class _ContactSelectionSheetState extends State<_ContactSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<models.EmergencyContact> _selected = [];
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _searchController.dispose();
    super.dispose();
  }

  void _pop(BuildContext context) {
    // Dismiss keyboard first to stop viewInsets-triggered rebuilds
    FocusScope.of(context).unfocus();
    Navigator.pop(
      context,
      List<models.EmergencyContact>.from(_selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.available
        : widget.available
            .where(
              (c) =>
                  c.name.toLowerCase().contains(query) ||
                  c.phone.toLowerCase().contains(query),
            )
            .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: appColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Contacts',
              style: appFonts.heading2Bold.copyWith(color: appColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              '${_selected.length} contact(s) selected',
              style: appFonts.textSmRegular.copyWith(color: appColors.textSecondary),
            ),
            SizedBox(height: 16.h),

            // ── Search field ───────────────────────────────────────────────
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: appFonts.textMdRegular.copyWith(color: appColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or phone…',
                hintStyle: appFonts.textSmRegular.copyWith(
                  color: appColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: appColors.textSecondary,
                  size: 20.sp,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: appColors.textSecondary,
                          size: 18.sp,
                        ),
                        onPressed: () => setState(() => _searchController.clear()),
                      )
                    : null,
                filled: true,
                fillColor: appColors.textSecondary.withOpacity(0.07),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: appColors.textSecondary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ── Contact list ───────────────────────────────────────────────
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40.sp,
                            color: appColors.textSecondary.withOpacity(0.4),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No contacts match "$query"',
                            style: appFonts.textSmRegular.copyWith(
                              color: appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: appColors.textSecondary.withOpacity(0.1),
                      ),
                      itemBuilder: (_, index) {
                        final contact = filtered[index];
                        final isSelected = _selected.contains(contact);
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          title: Text(
                            contact.name,
                            style: appFonts.textMdMedium.copyWith(
                              color: appColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            contact.phone,
                            style: appFonts.textSmRegular.copyWith(
                              color: appColors.textSecondary,
                            ),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (value) => setState(() {
                              value == true
                                  ? _selected.add(contact)
                                  : _selected.remove(contact);
                            }),
                          ),
                          onTap: () => setState(() {
                            isSelected
                                ? _selected.remove(contact)
                                : _selected.add(contact);
                          }),
                        );
                      },
                    ),
            ),

            SizedBox(height: 16.h),
            RideNowButton(
              title: _selected.isEmpty
                  ? 'Select at least one contact'
                  : 'Add ${_selected.length} Contact${_selected.length > 1 ? "s" : ""}',
              onTap: _selected.isEmpty ? null : () => _pop(context),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }
}
