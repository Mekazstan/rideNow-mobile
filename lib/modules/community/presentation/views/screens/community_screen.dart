import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/emergency_contact_provider.dart';
import 'package:ridenowappsss/modules/community/presentation/providers/community_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/views/widgets/contact_selection_sheet.dart';
import 'package:ridenowappsss/modules/authentication/domain/services/contact_services.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class CommunityScreen extends StatefulWidget {
  final bool showBackButton;
  const CommunityScreen({super.key, this.showBackButton = false});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyContactProvider>().fetchEmergencyContacts();
      context.read<CommunityProvider>().fetchSharedRides();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<EmergencyContactProvider>().updateSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: widget.showBackButton,
          leading: widget.showBackButton
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: appColors.gray900, size: 20.sp),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Text(
            'Community Sharing',
            style: appFonts.heading1Bold.copyWith(
              fontSize: 20.sp,
              color: appColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            indicatorColor: appColors.blue600,
            indicatorWeight: 2,
            labelColor: appColors.blue600,
            unselectedLabelColor: appColors.gray400,
            labelStyle: appFonts.textBaseMedium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Contacts'),
              Tab(text: 'Watch ride'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ContactsTab(),
            WatchRideTab(),
          ],
        ),
      ),
    );
  }
}

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  Future<void> _handlePickContacts(BuildContext context) async {
    final provider = context.read<EmergencyContactProvider>();
    final contactService = ContactService();
    try {
      final deviceContacts = await contactService.fetchDeviceContacts();

      if (!context.mounted) return;

      final available = deviceContacts
          .where((c) => !provider.emergencyContacts.any((ec) => ec.phone == c.phone))
          .toList();

      if (available.isEmpty) {
        ToastService.showInfo('All device contacts are already added');
        return;
      }

      final List<EmergencyContact>? selected =
          await showModalBottomSheet<List<EmergencyContact>>(
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
          await provider.createEmergencyContact(
            name: contact.name,
            phone: contact.phone,
            email: contact.email,
          );
        }
        ToastService.showSuccess(
            '${selected.length} contact${selected.length > 1 ? "s" : ""} added successfully');
      }
    } catch (e) {
      debugPrint('Error picking contacts: $e');
      ToastService.showError('Failed to fetch contacts');
    }
  }


  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            // Tip section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: appColors.blue600,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.location_on, color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Your contacts can watch your ride making it safer for you',
                      style: appFonts.textSmRegular.copyWith(
                        color: appColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Search field
            TextField(
              onChanged:
                  (value) => context
                      .read<EmergencyContactProvider>()
                      .updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: Icon(Icons.search, color: appColors.gray400),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide(color: appColors.blue200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide(color: appColors.blue600, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Contacts list
            Consumer<EmergencyContactProvider>(
              builder: (context, provider, _) {
                final contacts = provider.filteredEmergencyContacts;

                if (contacts.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
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
                      SizedBox(height: 40.h),
                      GestureDetector(
                        onTap: () => _handlePickContacts(context),
                        child: Container(
                          height: 49.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: appColors.blue700,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/add.svg',
                                colorFilter: ColorFilter.mode(
                                  appColors.textWhite,
                                  BlendMode.srcIn,
                                ),
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
                      SizedBox(height: 31.h),
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == contacts.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: GestureDetector(
                          onTap: () => _handlePickContacts(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: appColors.blue600,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Add new contact',
                                style: appFonts.textBaseMedium.copyWith(
                                  color: appColors.blue600,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final contact = contacts[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: appColors.pink500,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    contact.name,
                                    style: appFonts.textBaseMedium.copyWith(
                                      color: appColors.textPrimary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                () => provider.removeEmergencyContact(
                                  contact.id,
                                ),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: appColors.red50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.person_remove_outlined,
                                color: appColors.red400,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WatchRideTab extends StatelessWidget {
  const WatchRideTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Consumer<CommunityProvider>(
      builder: (context, provider, _) {
        final liveRides = provider.sharedRides;

        if (liveRides.isEmpty) {
          return Center(
            child: Text(
              'None of your friends are on a ride',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textSecondary,
                fontSize: 16.sp,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: liveRides.length,
          itemBuilder: (context, index) {
            final ride = liveRides[index];
            return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: appColors.blue50.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: appColors.blue50, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: DecorationImage(
                    image: ride.driver.photo != null
                        ? NetworkImage(ride.driver.photo!)
                        : const AssetImage(
                            'assets/profile_placeholder.png',
                          ) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: appFonts.textSmRegular.copyWith(
                      color: appColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                    children: [
                      TextSpan(
                        text: '${ride.riderName} ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: 'is live now'),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to live tracking screen
                },
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, color: appColors.blue600, size: 18.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Watch live',
                      style: appFonts.textSmMedium.copyWith(
                        color: appColors.blue600,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
