// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';
import 'package:ridenowappsss/modules/authentication/domain/services/contact_services.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/emergency_contact_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/contact_list_shimmer.dart';

class ContactPickerBottomSheet extends StatefulWidget {
  const ContactPickerBottomSheet({super.key});

  @override
  State<ContactPickerBottomSheet> createState() =>
      _ContactPickerBottomSheetState();
}

class _ContactPickerBottomSheetState extends State<ContactPickerBottomSheet> {
  final ContactService _contactService = ContactService();
  final TextEditingController _searchController = TextEditingController();

  List<EmergencyContact> _allContacts = [];
  List<EmergencyContact> _filteredContacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contacts = await _contactService.fetchDeviceContacts();
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts =
            _allContacts.where((contact) {
              return contact.name.toLowerCase().contains(query.toLowerCase()) ||
                  contact.phoneNumber.contains(query);
            }).toList();
      }
    });
  }

  void _handleContactSelection(BuildContext context, EmergencyContact contact) {
    final provider = Provider.of<EmergencyContactProvider>(
      context,
      listen: false,
    );

    if (provider.isContactAdded(contact.id)) {
      _showSnackBar(context, '${contact.name} is already added');
      return;
    }

    provider.addEmergencyContact(contact);
    _showSnackBar(context, '${contact.name} added successfully');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: appColors.textWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          _buildHandleBar(appColors),
          _buildHeader(appColors, appFonts),
          _buildSearchBar(appColors),
          SizedBox(height: 16.h),
          Expanded(child: _buildContactList(context, appColors, appFonts)),
        ],
      ),
    );
  }

  Widget _buildHandleBar(AppColorExtension appColors) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: appColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select Contact',
            style: appFonts.heading2Bold.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppColorExtension appColors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: _searchController,
        onChanged: _filterContacts,
        decoration: InputDecoration(
          hintText: 'Search contacts',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildContactList(
    BuildContext context,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    if (_isLoading) {
      return const ContactListShimmer();
    }

    if (_errorMessage != null) {
      return _buildErrorState(appColors, appFonts);
    }

    if (_filteredContacts.isEmpty) {
      return _buildEmptyState(appColors, appFonts);
    }

    return Consumer<EmergencyContactProvider>(
      builder: (context, provider, _) {
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: _filteredContacts.length,
          separatorBuilder: (_, __) => Divider(height: 1.h),
          itemBuilder: (context, index) {
            final contact = _filteredContacts[index];
            final isAdded = provider.isContactAdded(contact.id);

            return ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 8.h,
              ),
              leading: CircleAvatar(
                backgroundColor: appColors.blue700.withOpacity(0.1),
                child: Text(
                  contact.name[0].toUpperCase(),
                  style: appFonts.textMdBold.copyWith(color: appColors.blue700),
                ),
              ),
              title: Text(
                contact.name,
                style: appFonts.textMdMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                contact.phoneNumber,
                style: appFonts.textSmRegular.copyWith(
                  color: appColors.textSecondary,
                ),
              ),
              trailing: Icon(
                isAdded ? Icons.check_circle : Icons.add_circle_outline,
                color: isAdded ? appColors.green300 : appColors.blue700,
                size: 24.sp,
              ),
              onTap: () => _handleContactSelection(context, contact),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: appColors.red300),
          SizedBox(height: 16.h),
          Text('Failed to load contacts', style: appFonts.textMdBold),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: appFonts.textSmRegular.copyWith(
                color: appColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(onPressed: _loadContacts, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contacts_outlined,
            size: 64.sp,
            color: appColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No contacts found',
            style: appFonts.textMdMedium.copyWith(
              color: appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
