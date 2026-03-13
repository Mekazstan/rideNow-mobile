// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
import 'package:ridenowappsss/modules/authentication/domain/services/contact_services.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/emergency_contact_provider.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_search_bar.dart';
import 'package:ridenowappsss/shared/widgets/step_indicator.dart';

class EmergencyContact extends StatefulWidget {
  const EmergencyContact({super.key});

  @override
  State<EmergencyContact> createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  final TextEditingController _searchController = TextEditingController();
  final ContactService _contactService = ContactService();
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
    _loadStoredContacts();
  }

  /// Initialize Smile ID SDK
  Future<void> _initializeSmileID() async {
    try {
      await _smileService.initialize();
      debugPrint('âœ… Smile ID initialized successfully');
    } catch (e) {
      debugPrint('âŒ Failed to initialize Smile ID: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize verification service: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Load previously stored contacts
  Future<void> _loadStoredContacts() async {
    try {
      final provider = Provider.of<EmergencyContactProvider>(
        context,
        listen: false,
      );
      final storedContacts = await _storageService.getEmergencyContacts();

      for (final contact in storedContacts) {
        provider.addEmergencyContact(contact);
      }

      debugPrint('âœ… Loaded ${storedContacts.length} stored contacts');
    } catch (e) {
      debugPrint('âŒ Failed to load stored contacts: $e');
    }
  }

  /// Handle Add Contacts button press
  Future<void> _handleAddContactsPressed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<EmergencyContactProvider>(
        context,
        listen: false,
      );

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

      int addedCount = 0;
      for (final contact in deviceContacts) {
        if (!provider.emergencyContacts.any((c) => c.id == contact.id)) {
          provider.addEmergencyContact(contact);
          addedCount++;
        }
      }

      await _storageService.saveEmergencyContacts(provider.emergencyContacts);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              addedCount > 0
                  ? '$addedCount contact${addedCount > 1 ? 's' : ''} added successfully'
                  : 'All contacts already added',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: addedCount > 0 ? Colors.green : Colors.blue,
          ),
        );
      }

      // After adding contacts, proceed to verification
      if (addedCount > 0 || provider.hasEmergencyContacts) {
        await _startSmileIDVerification();
      }
    } catch (e) {
      debugPrint('âŒ Error adding contacts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Start Smile ID Verification with Native WebView
  Future<void> _startSmileIDVerification() async {
    if (_isVerifying || !_smileService.isInitialized) {
      debugPrint(
        'âš ï¸ Cannot start verification: isVerifying=$_isVerifying, isInitialized=${_smileService.isInitialized}',
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final user = await _storageService.getUserData();

      if (user == null) {
        throw Exception('User data not found. Please log in again.');
      }

      // Generate or use existing user ID
      final userId = user.id;

      debugPrint('ðŸš€ Starting Smile ID verification for user: $userId');

      // Launch Smile ID native web view UI
      final result = await _smileService.startEnhancedKycWithUI(
        context: context,
        userId: userId,
        country: 'NG',
        // Optional: pre-fill user data if available
        firstName: user.firstName,
        lastName: user.lastName,
      );

      // Handle result
      if (result != null) {
        if (result.success) {
          // Save verification status
          await _storageService.setSmileIdVerified(true);

          debugPrint('âœ… Verification successful: ${result.data}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Identity verification completed successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            // Wait a bit to show the success message
            await Future.delayed(const Duration(milliseconds: 1500));
            _navigateToRideScreen();
          }
        } else {
          // Verification failed or was cancelled
          debugPrint('âš ï¸ Verification failed: ${result.message}');

          if (mounted) {
            _showVerificationFailedDialog(
              message: result.message ?? 'Verification was cancelled or failed',
            );
          }
        }
      } else {
        // Result is null (shouldn't happen but handle it)
        debugPrint('âš ï¸ Verification returned null');

        if (mounted) {
          _showVerificationFailedDialog(
            message: 'Verification process was interrupted',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('âŒ Verification error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        _showVerificationFailedDialog(
          message: 'Verification failed: ${e.toString()}',
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
      final userType = authProvider.user?.userType.toLowerCase() ?? 'rider';

      if (userType == 'driver') {
        context.goNamed(RouteConstants.selectPaymentPlan);
      } else {
        context.goNamed(RouteConstants.ride);
      }
    } catch (e) {
      debugPrint('âŒ Navigation error: $e');
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToRideScreen();
                },
                child: Text(
                  'Continue Without Verification',
                  style: appFonts.textMdMedium.copyWith(
                    color: appColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Retry verification
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _startSmileIDVerification();
                  });
                },
                child: Text(
                  'Try Again',
                  style: appFonts.textMdMedium.copyWith(
                    color: appColors.blue700,
                  ),
                ),
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
            const StepIndicator(
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
                return provider.hasEmergencyContacts
                    ? RideNowSearchBar(
                      hintText: 'Search Contacts',
                      controller: _searchController,
                      onChanged: (query) => _handleSearch(query, provider),
                    )
                    : const SizedBox.shrink();
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
            _buildAddContactsButton(appColors, appFonts),
            SizedBox(height: 3.h),
            _buildSkipButton(appColors, appFonts),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No friend found',
          style: appFonts.textSmMedium.copyWith(
            color: appColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16.h),
        Image.asset('assets/groups.png'),
      ],
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
                  contact.phoneNumber,
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

    return GestureDetector(
      onTap: isDisabled ? null : _handleAddContactsPressed,
      child: Container(
        height: 49.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              isDisabled
                  ? appColors.blue700.withOpacity(0.5)
                  : appColors.blue700,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child:
              _isLoading
                  ? Center(
                    child: SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        color: appColors.textWhite,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/add.svg',
                        color: appColors.textWhite,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Contacts',
                        style: appFonts.textMdBold.copyWith(
                          color: appColors.textWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return GestureDetector(
      onTap: _isVerifying ? null : () => _startSmileIDVerification(),
      child: Center(
        child:
            _isVerifying
                ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    color: appColors.blue600,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'Skip',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.blue600,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
      ),
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
                  await _storageService.removeEmergencyContact(contact.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${contact.name} removed'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
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
