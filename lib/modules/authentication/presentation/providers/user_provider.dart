import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';

enum UserType { rider, driver, vendor }

extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.rider:
        return 'rider';
      case UserType.driver:
        return 'driver';
      case UserType.vendor:
        return 'vendor';
    }
  }

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'rider':
        return UserType.rider;
      case 'driver':
        return UserType.driver;
      case 'vendor':
        return UserType.vendor;
      default:
        return UserType.rider;
    }
  }
}

class UserProvider extends ChangeNotifier {
  UserType? _selectedUserType;

  // Getter
  UserType? get selectedUserType => _selectedUserType;

  /// Set user type (used during pre-auth selection)
  void setUserType(UserType userType) {
    _selectedUserType = userType;
    notifyListeners();
  }

  /// Clear user type
  void clearUserType() {
    _selectedUserType = null;
    notifyListeners();
  }

  /// Reset all data
  void reset() {
    _selectedUserType = null;
    notifyListeners();
  }
}

// ============================================================
// 3. HELPER EXTENSION - Get user info from AuthProvider
// ============================================================

/// Extension to easily access user info from AuthProvider
extension AuthProviderUserExtension on AuthProvider {
  /// Get user type as string (lowercase)
  String get userTypeString => user?.userType.toLowerCase() ?? 'rider';

  /// Check if user is verified
  bool get isUserVerified =>
      user?.verificationStatus.toLowerCase() == 'verified';

  /// Check if onboarding is completed
  bool get isOnboardingCompleted => user?.emailVerified ?? false;

  /// Check if verification is pending
  bool get isVerificationPending =>
      user?.verificationStatus.toLowerCase() == 'pending';

  /// Check if user needs verification
  bool get needsVerification {
    final status = user?.verificationStatus.toLowerCase();
    return status == null || status == 'unverified';
  }
}
