import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/services/error_service.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/choose_bank_account.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/deposit_bottom_sheet.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/wallet_balance_card.dart';
import 'package:ridenowappsss/modules/wallet/presentation/views/widgets/wallet_widgets.dart';
import 'package:ridenowappsss/shared/widgets/navigation_button.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_bottomsheet.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_side_menu_driver.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWallet();
      _setupScrollListener();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isNearBottom()) return;

    final provider = _getWalletProvider(listen: false);
    if (provider.hasMorePages && !provider.isLoadingMore) {
      provider.loadMoreTransactions();
    }
  }

  bool _isNearBottom() {
    return _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
  }

  Future<void> _initializeWallet() async {
    final provider = _getWalletProvider(listen: false);
    await provider.initializeWallet();
    _handleError(provider);
  }

  Future<void> _refreshWallet() async {
    final provider = _getWalletProvider(listen: false);
    await provider.refreshWallet();
    _handleError(provider);
  }

  void _handleError(WalletProvider provider) {
    if (provider.hasError && provider.lastError != null) {
      ErrorService.handleError(provider.lastError!);
    }
  }

  WalletProvider _getWalletProvider({bool listen = false}) {
    return Provider.of<WalletProvider>(context, listen: listen);
  }

  Widget _getDrawer() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userType = authProvider.user?.userType.toLowerCase() ?? 'rider';

        return userType == 'driver'
            ? const RideNowSideMenuDriver()
            : const RideNowSideMenu();
      },
    );
  }

  void _showWithdrawBottomSheet() {
    RideNowBottomSheet.show(
      context: context,
      height: 389.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      hideBottomNav: false,
      child: const ChooseBankAccount(),
    );
  }

  void _showDepositBottomSheet() {
    RideNowBottomSheet.show(
      context: context,
      height: 270.h,
      backgroundColor: Colors.white,
      borderRadius: 16.r,
      hideBottomNav: true,
      child: const DepositBottomSheetContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      drawer: _getDrawer(),
      body: SafeArea(
        child: Consumer<WalletProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: _refreshWallet,
              color: appColors.blue600,
              child: NestedScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NavigationButton(appColors: appColors),
                          SizedBox(height: 17.h),
                          WalletBalanceCard(
                            provider: provider,
                            onDeposit: _showDepositBottomSheet,
                            onWithdraw: _showWithdrawBottomSheet,
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ],
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: WalletTransactionsList(
                    provider: provider,
                    scrollController: _scrollController,
                    onRetry: _initializeWallet,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
