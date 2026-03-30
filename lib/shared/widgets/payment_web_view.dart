// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final Future<bool> Function(String reference)? onVerifyReference;
  final Future<bool> Function(String transactionId)? onVerifyTransaction;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final String? successMessage;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    this.onVerifyReference,
    this.onVerifyTransaction,
    this.onSuccess,
    this.onCancel,
    this.successMessage,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}


class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasProcessedCallback = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_hasProcessedCallback && mounted) {
        _checkPaymentStatusQuietly();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Checks payment status without showing loading dialogs
  Future<void> _checkPaymentStatusQuietly() async {
    if (_hasProcessedCallback || !mounted) return;

    try {
      debugPrint('Polling payment status for transaction: ${widget.transactionId}');
      
      bool isSuccessful = false;
      if (widget.onVerifyTransaction != null) {
        isSuccessful = await widget.onVerifyTransaction!(widget.transactionId);
      } else {
        final provider = Provider.of<WalletProvider>(context, listen: false);
        isSuccessful = await provider.verifyDeposit(widget.transactionId);
      }

      if (isSuccessful && mounted && !_hasProcessedCallback) {
        debugPrint('Polling detected successful payment!');
        _stopPolling();
        _navigateToRideScreen();
      }
    } catch (e) {
      debugPrint('Polling error (ignoring): $e');
    }
  }

  /// Sets up WebView with navigation handlers
  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                debugPrint('Page started: $url');
                if (mounted) {
                  setState(() => _isLoading = true);
                }
                _handleUrlNavigation(url);
              },
              onPageFinished: (String url) {
                debugPrint('Page finished: $url');
                if (mounted && !_hasProcessedCallback) {
                  setState(() => _isLoading = false);
                }
                _injectPaymentMethodSelection();
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Web resource error: ${error.description}');

                if (error.url?.contains('payment-callback') == true) {
                  debugPrint('Ignoring callback URL error - this is expected');
                  return;
                }

                if (mounted && !_hasProcessedCallback) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Failed to load payment page';
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                debugPrint('Navigation request: ${request.url}');

                if (_isCallbackUrl(request.url)) {
                  _handleUrlNavigation(request.url);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isCallbackUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('payment-callback') ||
        lowerUrl.contains('/callback');
  }

  /// Auto-selects the chosen payment method on payment page
  Future<void> _injectPaymentMethodSelection() async {
    if (_hasProcessedCallback) return;

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      String jsCode = '';

      if (widget.paymentMethod == 'bank_transfer') {
        jsCode = '''
          (function() {
            var bankTransferButton = document.querySelector('[data-payment-method="bank_transfer"]') ||
                                    document.querySelector('.bank-transfer') ||
                                    document.querySelector('[id*="bank"]') ||
                                    document.querySelector('[class*="bank"]');
            
            if (bankTransferButton) {
              bankTransferButton.click();
              return true;
            }
            
            var allButtons = document.querySelectorAll('button, a, div[role="button"], div[onclick]');
            for (var i = 0; i < allButtons.length; i++) {
              var btn = allButtons[i];
              var text = btn.textContent.toLowerCase();
              if (text.includes('bank') || text.includes('transfer')) {
                btn.click();
                return true;
              }
            }
            return false;
          })();
        ''';
      } else if (widget.paymentMethod == 'card') {
        jsCode = '''
          (function() {
            var cardButton = document.querySelector('[data-payment-method="card"]') ||
                           document.querySelector('.card-payment') ||
                           document.querySelector('[id*="card"]') ||
                           document.querySelector('[class*="card"]');
            
            if (cardButton) {
              cardButton.click();
              return true;
            }
            
            var allButtons = document.querySelectorAll('button, a, div[role="button"], div[onclick]');
            for (var i = 0; i < allButtons.length; i++) {
              var btn = allButtons[i];
              var text = btn.textContent.toLowerCase();
              if (text.includes('card') || text.includes('debit') || text.includes('credit')) {
                btn.click();
                return true;
              }
            }
            return false;
          })();
        ''';
      }

      if (jsCode.isNotEmpty) {
        await _controller.runJavaScript(jsCode);
      }
    } catch (e) {
      debugPrint('Failed to inject payment method selection: $e');
    }
  }

  /// Detects payment success/failure from URL patterns
  void _handleUrlNavigation(String url) {
    if (_hasProcessedCallback) return;

    final uri = Uri.parse(url.toLowerCase());
    final path = uri.path.toLowerCase();
    final query = uri.query.toLowerCase();
    final fullUrl = url.toLowerCase();

    if (path.contains('payment-callback') || path.contains('callback')) {
      _hasProcessedCallback = true;

      final originalUri = Uri.parse(url);
      final reference =
          originalUri.queryParameters['reference'] ??
          originalUri.queryParameters['trxref'] ??
          originalUri.queryParameters['tx_ref'];

      debugPrint('Callback URL detected: $url');
      debugPrint('Extracted reference: $reference');

      if (reference != null && reference.isNotEmpty) {
        _verifyAndNavigateToRide(reference);
      } else {
        _verifyPaymentAndNavigateToRide();
      }
      return;
    }

    bool isSuccess =
        path.contains('success') ||
        path.contains('completed') ||
        path.contains('approved') ||
        query.contains('status=success') ||
        query.contains('status=successful') ||
        query.contains('status=completed');

    bool isFailure =
        path.contains('failed') ||
        path.contains('cancelled') ||
        path.contains('canceled') ||
        path.contains('declined') ||
        query.contains('status=failed') ||
        query.contains('status=cancelled') ||
        query.contains('status=declined');

    if (fullUrl.contains('paystack') &&
        (query.contains('trxref') || query.contains('reference'))) {
      if (!query.contains('cancelled')) {
        isSuccess = true;
      } else {
        isFailure = true;
      }
    }

    if (fullUrl.contains('flutterwave') && query.contains('status')) {
      if (query.contains('status=successful')) {
        isSuccess = true;
      } else if (query.contains('status=cancelled')) {
        isFailure = true;
      }
    }

    if (isSuccess || isFailure) {
      _hasProcessedCallback = true;

      if (isSuccess) {
        final originalUri = Uri.parse(url);
        final reference =
            originalUri.queryParameters['reference'] ??
            originalUri.queryParameters['trxref'] ??
            originalUri.queryParameters['tx_ref'];

        if (reference != null && reference.isNotEmpty) {
          _verifyAndNavigateToRide(reference);
        } else {
          _verifyPaymentAndNavigateToRide();
        }
      } else {
        _handlePaymentFailure('Payment was cancelled or failed');
      }
    }
  }

  /// Verifies payment using payment reference
  Future<void> _verifyAndNavigateToRide(String reference) async {
    if (!mounted) return;

    _showLoadingDialog();

    try {
      debugPrint('Verifying payment with reference: $reference');

      bool isSuccessful;
      if (widget.onVerifyReference != null) {
        isSuccessful = await widget.onVerifyReference!(reference);
      } else {
        final provider = Provider.of<WalletProvider>(context, listen: false);
        isSuccessful = await provider.verifyPaymentCallback(reference);
        if (isSuccessful) await provider.refreshWallet();
      }

      if (!mounted) return;

      _dismissLoadingDialog();

      if (isSuccessful) {
        debugPrint('Payment verified successfully');
        _navigateToRideScreen();
      } else {
        debugPrint('Payment verification failed, showing error');
        _handlePaymentFailure(
          'Payment verification failed. Please check your transaction status.',
        );
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');

      if (!mounted) return;

      _dismissLoadingDialog();
      _handleVerificationError();
    }
  }

  /// Verifies payment using transaction ID
  Future<void> _verifyPaymentAndNavigateToRide() async {
    if (!mounted) return;

    _showLoadingDialog();

    try {
      debugPrint(
        'Verifying payment with transaction ID: ${widget.transactionId}',
      );

      bool isSuccessful;
      if (widget.onVerifyTransaction != null) {
        isSuccessful = await widget.onVerifyTransaction!(widget.transactionId);
      } else {
        final provider = Provider.of<WalletProvider>(context, listen: false);
        await Future.delayed(const Duration(seconds: 2));
        isSuccessful = await provider.verifyDeposit(widget.transactionId);
        if (isSuccessful) await provider.refreshWallet();
      }

      if (!mounted) return;

      _dismissLoadingDialog();

      if (isSuccessful) {
        debugPrint('Payment verified successfully');
        _navigateToRideScreen();
      } else {
        debugPrint('Payment verification by transaction ID failed');
        _handleVerificationError();
      }
    } catch (e) {
      debugPrint('Error verifying payment status: $e');

      if (!mounted) return;

      _dismissLoadingDialog();
      _handleVerificationError();
    }
  }

  /// Shows dialog when payment verification is unclear
  void _handleVerificationError() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final appColors = Theme.of(context).extension<AppColorExtension>()!;
        final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

        return AlertDialog(
          title: Text(
            'Payment Status Unclear',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'We couldn\'t verify your payment automatically. Please check your account to confirm if the payment was successful.',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.gray500,
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Close',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.gray500,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                if (widget.onSuccess != null) {
                  widget.onSuccess!();
                } else {
                  final provider = Provider.of<WalletProvider>(
                    context,
                    listen: false,
                  );
                  await provider.refreshWallet();

                  if (!mounted) return;

                  Navigator.of(context).pop(true);
                  if (context.mounted) {
                    context.goNamed(RouteConstants.wallet);
                  }
                }

                ToastService.showInfo('Please check your transaction status');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.blue600,
              ),
              child: Text(
                widget.onSuccess != null ? 'Continue' : 'Check Wallet',
                style: appFonts.textSmMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToRideScreen() {
    if (!mounted || _hasProcessedCallback) return;
    _hasProcessedCallback = true;
    _stopPolling();

    Navigator.of(context).pop(true);

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      context.goNamed(RouteConstants.wallet);
    }

    ToastService.showSuccess(
      widget.successMessage ?? 'Payment completed successfully!',
    );
  }

  void _handlePaymentFailure(String message) {
    if (!mounted || _hasProcessedCallback) return;
    _hasProcessedCallback = true;
    _stopPolling();

    Navigator.of(context).pop(false);

    ToastService.showWarning(message);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
    );
  }

  void _dismissLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _handleClosePress() async {
    // Before showing cancel dialog, do a quick status check
    if (!_hasProcessedCallback) {
      try {
        bool isSuccessful = false;
        if (widget.onVerifyTransaction != null) {
          isSuccessful = await widget.onVerifyTransaction!(widget.transactionId);
        } else {
          final provider = Provider.of<WalletProvider>(context, listen: false);
          isSuccessful = await provider.verifyDeposit(widget.transactionId);
        }

        if (isSuccessful && mounted) {
          _navigateToRideScreen();
          return;
        }
      } catch (e) {
        debugPrint('Close check error: $e');
      }
    }

    final shouldClose = await _showCancelDialog();
    if (shouldClose == true && mounted) {
      _stopPolling();
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          _handleClosePress();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Complete Payment',
            style: appFonts.textBaseMedium.copyWith(
              color: appColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.close, color: appColors.textPrimary),
            onPressed: _handleClosePress,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: appColors.gray200, height: 1),
          ),
        ),
        body: Stack(
          children: [
            if (_errorMessage != null)
              _buildErrorState(appColors, appFonts)
            else
              WebViewWidget(controller: _controller),
            if (_isLoading && _errorMessage == null)
              _buildLoadingState(appColors, appFonts),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: appColors.blue600),
            SizedBox(height: 16.h),
            Text(
              'Loading payment page...',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.gray500,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Amount: ₦${widget.amount.toStringAsFixed(2)}',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.pink500,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: appColors.red400),
              SizedBox(height: 16.h),
              Text(
                _errorMessage ?? 'Something went wrong',
                style: appFonts.textBaseMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Please check your internet connection and try again',
                style: appFonts.textSmRegular.copyWith(
                  color: appColors.gray500,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _initializeWebView();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.blue600,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: appFonts.textBaseMedium.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: appFonts.textBaseMedium.copyWith(
                    color: appColors.gray500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showCancelDialog() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Cancel Payment?',
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Are you sure you want to cancel this payment? Your transaction may not be completed.',
              style: appFonts.textSmRegular.copyWith(
                color: appColors.gray500,
                fontSize: 14.sp,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'No, Continue',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.blue600,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Yes, Cancel',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.red400,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
