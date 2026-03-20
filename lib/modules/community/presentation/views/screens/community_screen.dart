import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/emergency_contact_provider.dart';

class ShareRideScreen extends StatefulWidget {
  const ShareRideScreen({super.key});

  @override
  State<ShareRideScreen> createState() => _ShareRideScreenState();
}

class _ShareRideScreenState extends State<ShareRideScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedFriends = {};
  bool _selectAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildMapSection(appColors),
            ),
            Expanded(child: _buildShareSection(appColors, appFonts)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(AppColorExtension appColors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 250.h,
      child: Stack(
        children: [
          Consumer<RideProvider>(
            builder: (context, viewModel, _) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      viewModel.currentLocation?.toLatLng() ??
                      const LatLng(9.0820, 8.6753),
                  zoom: 15,
                ),
                markers: viewModel.markers,
                polylines: viewModel.polylines,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              );
            },
          ),
          Positioned(
            top: 16.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Back to ride',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: appColors.blue600,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.share_location,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Share your ride to your community',
                    style: appFonts.heading1Bold.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: appColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _buildDriverInfo(appColors, appFonts),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends',
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildSelectAllToggle(appColors, appFonts),
          SizedBox(height: 16.h),
          Expanded(child: _buildFriendsList(appColors, appFonts)),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Driver',
                      style: appFonts.textSmMedium.copyWith(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Ismail Bismillah',
                  style: appFonts.textMdBold.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                Text(
                  'Nissan lbv 322 Machine',
                  style: appFonts.textSmRegular.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.verified, color: Colors.green, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                '4',
                style: appFonts.textMdBold.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () {
              // Share to all logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Share to all',
              style: appFonts.textSmMedium.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllToggle(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Consumer<EmergencyContactProvider>(
      builder: (context, provider, _) {
        final contacts = provider.filteredEmergencyContacts;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Switch(
                value: _selectAll,
                onChanged: contacts.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _selectAll = value;
                          if (value) {
                            _selectedFriends.addAll(contacts.map((c) => c.id));
                          } else {
                            _selectedFriends.clear();
                          }
                        });
                      },
                activeColor: appColors.blue600,
              ),
              SizedBox(width: 12.w),
              Text(
                'Select friends to share',
                style: appFonts.textMdMedium.copyWith(
                  fontSize: 14.sp,
                  color: appColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFriendsList(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Consumer<EmergencyContactProvider>(
      builder: (context, provider, _) {
        final contacts = provider.filteredEmergencyContacts;

        if (provider.isSyncing && contacts.isEmpty) {
          return Center(child: CircularProgressIndicator(color: appColors.blue700));
        }

        if (contacts.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.searchQuery.isNotEmpty ? 'No results found' : 'No friend found',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 16.h),
              Image.asset('assets/groups.png', height: 100.h),
            ],
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final friendId = contact.id;
            final isSelected = _selectedFriends.contains(friendId);

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: appColors.blue700.withOpacity(0.1),
                    child: Text(
                      contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                      style: appFonts.textMdBold.copyWith(color: appColors.blue700),
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: appColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          contact.phoneNumber,
                          style: appFonts.textSmRegular.copyWith(
                            color: appColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedFriends.add(friendId);
                        } else {
                          _selectedFriends.remove(friendId);
                          _selectAll = false;
                        }
                      });
                    },
                    activeColor: appColors.blue600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
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
