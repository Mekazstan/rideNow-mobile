import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class PersonalInfoSection extends StatefulWidget {
  const PersonalInfoSection({
    super.key,
    required this.appColors,
    required this.appFonts,
  });

  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  bool _isEditing = false;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  String _formatDateForDisplay(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final parsed = DateTime.parse(isoDate);
      return DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {
      return isoDate;
    }
  }

  String _formatDateForApi(String displayDate) {
    if (displayDate.isEmpty) return '';
    try {
      final parsed = DateFormat('MMMM d, yyyy').parse(displayDate);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return displayDate;
    }
  }

  DateTime? _parseDisplayDate(String displayDate) {
    if (displayDate.isEmpty) return null;
    try {
      return DateFormat('MMMM d, yyyy').parse(displayDate);
    } catch (_) {
      return DateTime.tryParse(displayDate);
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phone);
    _dobController = TextEditingController(text: _formatDateForDisplay(user?.dateOfBirth));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _formatDateForApi(_dobController.text.trim()),
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ToastService.showSuccess('Profile updated successfully');
    } else if (mounted) {
      ToastService.showError(authProvider.errorMessage ?? 'Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();

        final joinedDate = DateTime.tryParse(user.createdAt);
        final formattedJoined = joinedDate != null 
            ? DateFormat('MMMM d, y').format(joinedDate)
            : 'Unknown';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: widget.appFonts.textSmMedium.copyWith(
                    color: widget.appColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_isEditing) {
                      _handleSave();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  child: Text(
                    _isEditing ? 'Save' : 'Edit',
                    style: widget.appFonts.textSmMedium.copyWith(
                      color: widget.appColors.blue500,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: widget.appColors.blue50.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: widget.appColors.blue100),
              ),
              child: Column(
                children: [
                  _buildInfoRow('First Name', _firstNameController, _isEditing),
                  _buildDivider(),
                  _buildInfoRow('Last Name', _lastNameController, _isEditing),
                  _buildDivider(),
                  _buildInfoRow('Email Address', TextEditingController(text: user.email), false),
                  _buildDivider(),
                  _buildInfoRow('Phone Number', _phoneController, _isEditing),
                  _buildDivider(),
                  _buildInfoRow('Date of Birth', _dobController, _isEditing, isDate: true),
                  _buildDivider(),
                  _buildReadOnlyRow('Member Since', formattedJoined),
                ],
              ),
            ),
            if (_isEditing) ...[
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: Center(
                  child: Text(
                    'Cancel Editing',
                    style: widget.appFonts.textSmMedium.copyWith(
                      color: widget.appColors.red500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller, bool isEditable, {bool isDate = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: widget.appFonts.textSmMedium.copyWith(
                color: widget.appColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isEditable
                ? TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: widget.appColors.blue200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: widget.appColors.blue100),
                      ),
                    ),
                    style: widget.appFonts.textSmMedium.copyWith(
                      color: widget.appColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                    onTap: isDate ? () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _parseDisplayDate(controller.text) ?? DateTime(1990),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        controller.text = DateFormat('MMMM d, yyyy').format(picked);
                      }
                    } : null,
                    readOnly: isDate,
                  )
                : Text(
                    controller.text,
                    textAlign: TextAlign.right,
                    style: widget.appFonts.textSmMedium.copyWith(
                      color: widget.appColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: widget.appFonts.textSmMedium.copyWith(
              color: widget.appColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: widget.appFonts.textSmMedium.copyWith(
              color: widget.appColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: widget.appColors.blue100.withOpacity(0.5), height: 1.h);
  }
}
