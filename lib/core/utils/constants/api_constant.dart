/// API configuration constants
class ApiConstants {
  ApiConstants._();

  // Google Maps API
  static const String googleMapsApiKey =
      'AIzaSyD7T_mhOQVLdfPuEVCyWjMv7fRO4DXZ73I';
  static const String googleMapsBaseUrl =
      'https://maps.googleapis.com/maps/api';
  static const String baseUrl = 'https://192.168.1.129:3000';
  static const String countryCode = 'ng';
  static const int searchRadiusMeters = 50000;

  // Auth Endpoints
  static const String profileEndpoint = '/auth/profile';
  static const String uploadProfilePhotoEndpoint = '/auth/profile/photo';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String loginEndpoint = '/auth/signin';
  static const String logoutEndpoint = '/auth/logout';

  // Wallet API Endpoints
  static const String walletBalanceEndpoint = '/wallets/balance';
  static const String walletTransactionsEndpoint = '/wallets/transactions';
  static const String withdrawalPinEndpoint = '/wallets/withdrawal-pin';
  static const String withdrawEndpoint = '/wallets/withdraw';
  static const String paymentCallbackEndpoint = '/wallets/payment-callback';

  // Support Endpoints
  static const String ambulanceServicesEndpoint =
      '/emergencys/ambulance-services';
  static const String policeStationsEndpoint = '/emergencys/police-stations';
  static const String privacySettingsEndpoint = '/emergencys/privacy-settings';
  static const String faqsEndpoint = '/supports/helps/faqs';
  static const String ticketsEndpoint = '/supports/tickets';

  // Bank Account Endpoints
  static const String bankAccountsEndpoint = '/wallets/bank-accounts';
  static const String addBankAccountEndpoint = '/wallets/bank-accounts';
  static const String validateBankAccountEndpoint = '/wallets/verify-account';
  static const String banksListEndpoint = '/wallets/banks';

  // Ride Endpoints
  static const String createRideEndpoint = '/rides/create';
  static const String getRideDetailsEndpoint = '/rides';
  static const String cancelRideEndpoint = '/rides/cancel';
  static const String selectDriverEndpoint = '/rides/{rideId}/select-driver';

  // Driver Endpoints
  static const String driverRideRequestsEndpoint = '/drivers/ride-requests';
  static const String acceptRideEndpoint = '/drivers/accept-ride';
  static const String rejectRideEndpoint = '/drivers/reject-ride';
  static const String getAvailableDriversEndpoint =
      '/rides/{rideId}/available-drivers';
  static const String getCounterOffersEndpoint =
      '/rides/{rideId}/counter-offers';
  static const String getRideStatusEndpoint = '/rides/{rideId}/status-update';
  static const String getRideCodeEndpoint = '/rides/{rideId}/code';
  static const String acceptCounterOfferEndpoint =
      '/rides/{rideId}/counter-offers/{offerId}/accept';
  static const String declineCounterOfferEndpoint =
      '/rides/{rideId}/counter-offers/{offerId}/decline';

  static const String driverDailyLimitStatusEndpoint = '/drivers/status';
  static const String driverEarningsAnalyticsEndpoint = '/drivers/analytics/earnings';
  static const String driverPerformanceAnalyticsEndpoint = '/drivers/analytics/performance';
  static const String driverRatingsAnalyticsEndpoint = '/drivers/analytics/ratings';
  static const String driverWeeklySummaryEndpoint = '/drivers/analytics/weekly-summary';

  // Pagination
  static const int defaultPerPage = 20;
  static const int maxPerPage = 100;

  // Token Configuration
  static const Duration tokenValidityDuration = Duration(hours: 2);
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);
  static const Duration tokenCheckInterval = Duration(minutes: 1);

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration placesTimeout = Duration(seconds: 25);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Bank Validation
  static const Duration bankValidationDelay = Duration(milliseconds: 800);
  static const int accountNumberLength = 10;

  // Profile Photo Upload
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedPhotoExtensions = ['jpg', 'jpeg', 'png'];
}

/// Map configuration constants
class MapConstants {
  MapConstants._();

  // Zoom levels
  static const double defaultZoom = 15.0;
  static const double minZoom = 2.0;
  static const double maxZoom = 20.0;

  // Route styling
  static const double routeBoundsPadding = 300.0;
  static const int polylineWidth = 5;

  // Default location (Benin City, Nigeria)
  static const double defaultLatitude = 6.3350;
  static const double defaultLongitude = 5.6037;

  // Camera animation
  static const Duration cameraAnimationDuration = Duration(milliseconds: 500);
}

/// Wallet-specific constants
class WalletConstants {
  WalletConstants._();

  // Transaction types
  static const String typeDeposit = 'deposit';
  static const String typeWithdrawal = 'withdrawal';
  static const String typePayment = 'payment';

  // Transaction statuses
  static const String statusSuccessful = 'successful';
  static const String statusSuccess = 'success';
  static const String statusCompleted = 'completed';
  static const String statusPending = 'pending';
  static const String statusFailed = 'failed';

  // Currency
  static const String defaultCurrency = 'NGN';

  // Formatting
  static const int decimalPlaces = 2;

  // Withdrawal PIN
  static const int withdrawalPinLength = 4;

  // Error messages
  static const String networkError = 'Network error. Please try again.';
  static const String unknownError = 'An unexpected error occurred';
  static const String loadTransactionsError = 'Failed to load transactions';
  static const String loadBalanceError = 'Failed to load balance';
  static const String withdrawalPinError = 'Failed to create withdrawal PIN';
  static const String withdrawalError = 'Failed to process withdrawal';
  static const String invalidPinError = 'Invalid withdrawal PIN';
}

/// Ride-specific constants
class RideConstants {
  RideConstants._();

  // Vehicle types (must match backend)
  static const String vehicleStandard = 'standard_ride';
  static const String vehicleLuxury = 'luxury';
  static const String vehicleBike = 'bike';
  static const String vehicleTricycle = 'tricycle';
  static const String vehicleSeaterBus = 'seater_bus';

  // Payment methods
  static const String paymentWallet = 'wallet';
  static const String paymentCard = 'card';
  static const String paymentCash = 'cash';

  // Ride statuses
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Error messages
  static const String createRideError = 'Failed to create ride';
  static const String insufficientBalanceError = 'Insufficient wallet balance';
  static const String invalidLocationError = 'Invalid pickup or destination';
}

/// Bank validation constants
class BankValidationConstants {
  BankValidationConstants._();

  // Error messages
  static const String selectBankError = 'Please select a bank first';
  static const String invalidFormatError = 'Account number must be 10 digits';
  static const String verificationError =
      'Unable to verify account. Please try again.';
  static const String accountNotFound = 'Account number not found';
  static const String invalidAccount = 'Invalid account number';

  // Validation rules
  static const int accountNumberLength = 10;
  static const String accountNumberPattern = r'^\d+$';
}

/// UI constants
class UIConstants {
  UIConstants._();

  // Loading
  static const int shimmerItemCount = 6;
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // Scroll
  static const double scrollThreshold = 200.0;

  // Animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

class WithdrawalConstants {
  static const int pinLength = 4;
  static const String defaultCurrency = 'NGN';
  static const String copySuccessMessage = 'Account number copied to clipboard';
  static const Duration snackBarDuration = Duration(seconds: 2);
}
