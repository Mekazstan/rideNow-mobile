import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/modules/wallet/data/models/payment_method_models.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/payment_method_service.dart';

class PaymentMethodProvider with ChangeNotifier {
  final PaymentMethodService _service;
  
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;
  PaymentMethod? _selectedMethod;

  PaymentMethodProvider({PaymentMethodService? service}) 
      : _service = service ?? PaymentMethodService();

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaymentMethod? get selectedMethod => _selectedMethod;

  /// Fetches saved payment methods
  Future<void> fetchPaymentMethods() async {
    _setLoading(true);
    _error = null;
    
    try {
      final methods = await _service.getPaymentMethods();
      _paymentMethods = methods;
      
      // Select default method if available
      if (_paymentMethods.isNotEmpty) {
        _selectedMethod = _paymentMethods.firstWhere(
          (m) => m.isDefault,
          orElse: () => _paymentMethods.first,
        );
      }
    } catch (e) {
      _error = 'Failed to load payment methods: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Sets the selected payment method
  void setSelectedMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  /// Helper to get wallet balance if available
  double get walletBalance {
    final wallet = _paymentMethods.firstWhere(
      (m) => m.isWallet,
      orElse: () => PaymentMethod(
        id: 'wallet', 
        type: PaymentMethodType.wallet, 
        name: 'Wallet', 
        balance: 0.0,
      ),
    );
    return wallet.balance ?? 0.0;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
