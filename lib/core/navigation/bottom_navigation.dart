// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/theme/app_theme.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';

// ============================================================
// BOTTOM NAV VISIBILITY PROVIDER
// ============================================================

class BottomNavVisibilityProvider extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }
}

// ============================================================
// BOTTOM NAVIGATION SHELL
// ============================================================

class BottomNavShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const BottomNavShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).colors;
    final currentIndex = _calculateSelectedIndex(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: Consumer<BottomNavVisibilityProvider>(
        builder: (context, visibilityProvider, _) {
          return visibilityProvider.isVisible
              ? Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  backgroundColor: appColors.textWhite,
                  unselectedItemColor: appColors.gray300,
                  selectedItemColor: appColors.blue500,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: currentIndex,
                  onTap: (index) => _onItemTapped(index, context),
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/wallet.svg',
                        color:
                            currentIndex == 0
                                ? appColors.blue500
                                : appColors.gray300,
                      ),
                      label: 'Wallet',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/ride.svg',
                        color:
                            currentIndex == 1
                                ? appColors.blue500
                                : appColors.gray300,
                      ),
                      label: 'Ride',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/community.svg',
                        color:
                            currentIndex == 2
                                ? appColors.blue500
                                : appColors.gray300,
                      ),
                      label: 'Community',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/accounts.svg',
                        color:
                            currentIndex == 3
                                ? appColors.blue500
                                : appColors.gray300,
                      ),
                      label: 'Accounts',
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  int _calculateSelectedIndex(String path) {
    switch (path) {
      case '/wallet':
        return 0;
      case '/ride':
        return 1;
      case '/community':
        return 2;
      case '/accounts':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/wallet');
        break;
      case 1:
        context.go('/ride');
        break;
      case 2:
        context.go('/community');
        break;
      case 3:
        context.go('/accounts');
        break;
    }
  }
}

// ============================================================
// CONDITIONAL WIDGET BY USER TYPE
// ============================================================

class ConditionalWidget extends StatelessWidget {
  final Widget riderWidget;
  final Widget driverWidget;
  final Widget? vendorWidget;
  final Widget? defaultWidget;

  const ConditionalWidget({
    super.key,
    required this.riderWidget,
    required this.driverWidget,
    this.vendorWidget,
    this.defaultWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading state while user data is being fetched
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is null after loading, show default
        if (authProvider.user == null) {
          debugPrint('âš ï¸ ConditionalWidget: User is null, showing default');
          return defaultWidget ?? riderWidget;
        }

        // Get user type from the user object
        final userType = authProvider.user!.userType.toLowerCase();

        debugPrint('âœ… ConditionalWidget: User type is "$userType"');

        switch (userType) {
          case 'driver':
            debugPrint('ðŸš— Showing Driver Widget');
            return driverWidget;
          case 'vendor':
            debugPrint('ðŸª Showing Vendor Widget');
            return vendorWidget ?? riderWidget;
          case 'rider':
            debugPrint('ðŸš¶ Showing Rider Widget');
            return riderWidget;
          default:
            debugPrint(
              'âš ï¸ Unknown user type "$userType", defaulting to Rider',
            );
            return riderWidget;
        }
      },
    );
  }
}
