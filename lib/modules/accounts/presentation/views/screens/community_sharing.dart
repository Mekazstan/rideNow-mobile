// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/contact_sharing.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/watch_ride.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_account_appbar.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_tab_bar.dart';

class CommunitySharing extends StatefulWidget {
  const CommunitySharing({super.key});

  @override
  State<CommunitySharing> createState() => _CommunitySharingState();
}

class _CommunitySharingState extends State<CommunitySharing> {
  int selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              RideNowAccountAppBar(
                appFonts: appFonts,
                appColors: appColors,
                title: 'Community Sharing',
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: RideNowTabBar(
                  firstTabText: 'Contacts',
                  secondTabText: 'Watch ride',
                  appFonts: appFonts,
                  appColors: appColors,
                  initialTabIndex: 0,
                  firstTabContent: ContactsAdding(),
                  secondTabContent: WatchRide(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
