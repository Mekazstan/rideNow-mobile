import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/faq_widget.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/submit_ticket.dart';
import 'package:ridenowappsss/modules/accounts/presentation/views/widgets/my_tickets_widget.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_account_appbar.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/ride_now_tab_bar.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              RideNowAccountAppBar(
                appFonts: appFonts,
                appColors: appColors,
                title: 'Help Center',
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: RideNowTabBar(
                  tabs: const ['FAQs', 'Submit Ticket', 'My Tickets'],
                  tabContents: const [
                    FaqWidget(),
                    SubmitTicket(),
                    MyTicketsWidget(),
                  ],
                  appFonts: appFonts,
                  appColors: appColors,
                  initialTabIndex: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
