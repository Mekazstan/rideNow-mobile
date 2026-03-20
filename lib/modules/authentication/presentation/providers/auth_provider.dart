import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/core/services/token_manager_service.dart';
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';
import 'package:ridenowappsss/modules/authentication/domain/services/auth_services.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';
import 'package:ridenowappsss/core/storage/ride_persistence.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();
  final TokenManagerService _tokenManager = TokenManagerService();

  // ============================================================
  // STATE VARIABLES
  // ============================================================

  AuthState _authState = AuthState.initial;
  User? _user;
  String? _token;
  String? _refreshToken;
  Exception? _lastError;
  Map<String, String>? _validationErrors;
  String? _nextStep;

  String? _tempEmail;
  String? _tempPassword;
  String? _tempConfirmPassword;

  bool _isUploadingPhoto = false;

  Function()? onSessionExpired;

  // ============================================================
  // GETTERS
  // ============================================================

  AuthState get authState => _authState;
  User? get user => _user;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  Exception? get lastError => _lastError;
  Map<String, String>? get validationErrors => _validationErrors;
  String? get nextStep => _nextStep;
  String? get tempEmail => _tempEmail;
  String? get tempPassword => _tempPassword;
  String? get tempConfirmPassword => _tempConfirmPassword;
  bool get isUploadingPhoto => _isUploadingPhoto;

  bool get isLoading => _authState == AuthState.loading;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get hasError => _authState == AuthState.error;

  String? get errorMessage {
    if (_lastError == null) return null;
    if (_lastError is ApiException) return (_lastError as ApiException).message;
    if (_lastError is NetworkException) {
      return (_lastError as NetworkException).message;
    }
    if (_lastError is ValidationException) {
      return 'Please check your input and try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initializeAuth() async {
    try {
      _setAuthState(AuthState.loading);

      final isLoggedIn = await _storageService.isLoggedIn();
      final isSessionExpired = await _storageService.isSessionExpired();

      if (kDebugMode) {
        print('=== Initialize Auth ===');
        print('Is logged in: $isLoggedIn');
        print('Is session expired: $isSessionExpired');
      }

      if (isLoggedIn && !isSessionExpired) {
        final storedUser = await _storageService.getUserData();
        final storedToken = await _storageService.getAuthToken();
        final storedRefreshToken = await _storageService.getRefreshToken();

        if (storedUser != null &&
            storedToken != null &&
            storedRefreshToken != null) {
          _user = storedUser;
          _token = storedToken;
          _refreshToken = storedRefreshToken;

          _authService.setAuthToken(storedToken);
          _setAuthState(AuthState.authenticated);

          _startSessionMonitoring();
          fetchProfile();
          return;
        }
      }

      if (isSessionExpired) {
        if (kDebugMode) {
          print('Session expired - clearing auth data and ride state');
        }
        await _storageService.clearAuthData();
        await getIt<RidePersistenceService>().clearRideState();
      }

      _setAuthState(AuthState.unauthenticated);
    } catch (e) {
      if (kDebugMode) {
        print('Initialize auth error: $e');
      }
      _setError(NetworkException('Failed to initialize authentication'));
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<bool> deleteAccount() async {
    try {
      _authState = AuthState.loading;
      _clearErrors();
      notifyListeners();

      if (kDebugMode) {
        print('=== Deleting Account ===');
      }

      await _authService.deleteAccount();

      // Clear user data and ride state
      await getIt<RidePersistenceService>().clearRideState();
      await _storageService.clearAuthData();
      _user = null;
      _authState = AuthState.initial;
      notifyListeners();

      if (kDebugMode) {
        print('Account deleted successfully');
      }

      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected delete account error: $e');
      }
      _setError(NetworkException('Failed to delete account'));
      return false;
    }
  }

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  void _startSessionMonitoring() {
    _tokenManager.startSessionMonitoring(
      onExpired: () async {
        if (kDebugMode) {
          print('=== Session Expired - Auto Logout ===');
        }

        await logout();
        onSessionExpired?.call();
      },
    );
  }

  Future<bool> refreshAuthToken() async {
    try {
      if (_refreshToken == null) {
        await logout();
        return false;
      }

      final authResponse = await _authService.refreshToken(
        refreshToken: _refreshToken!,
      );

      await _storageService.updateAuthToken(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        tokenExpiresIn: authResponse.tokenExpiresIn ?? 7200,
      );

      _token = authResponse.token;
      _refreshToken = authResponse.refreshToken;

      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (kDebugMode) {
        print('=== LOGOUT STARTED ===');
        print('Current user: ${_user?.firstName} ${_user?.lastName}');
        print('Current user type: ${_user?.userType}');
      }

      // Don't set loading state here as it might interfere with navigation
      // _setAuthState(AuthState.loading);

      // Step 1: Stop session monitoring
      _tokenManager.stopMonitoring();
      if (kDebugMode) {
        print('âœ… Session monitoring stopped');
      }

      // Step 2: Call logout API (non-blocking if it fails)
      try {
        await _authService.logout();
        if (kDebugMode) {
          print('âœ… Logout API call successful');
        }
      } catch (e) {
        if (kDebugMode) {
          print('âš ï¸ Logout API call failed (continuing anyway): $e');
        }
        // Continue with local cleanup even if API fails
      }

      // Step 3: Clear secure storage and ride state
      await _storageService.clearAuthData();
      await getIt<RidePersistenceService>().clearRideState();

      if (kDebugMode) {
        print('âœ… Auth data and ride state cleared');
      }

      // Step 4: Clear all state variables
      _user = null;
      _token = null;
      _refreshToken = null;
      _nextStep = null;
      _clearErrors();
      clearTempSignUpData();

      if (kDebugMode) {
        print('âœ… All state variables cleared');
      }

      // Step 5: Set unauthenticated state and notify listeners
      _authState = AuthState.unauthenticated;
      notifyListeners();

      if (kDebugMode) {
        print('âœ… Auth state set to unauthenticated');
        print('=== LOGOUT COMPLETED SUCCESSFULLY ===');
      }
    } catch (e) {
      if (kDebugMode) {
        print('âŒ Critical logout error: $e');
        print('Forcing logout anyway...');
      }

      // Force logout even on error
      try {
        _tokenManager.stopMonitoring();
        await _storageService.clearAuthData();
        await getIt<RidePersistenceService>().clearRideState();
      } catch (storageError) {
        if (kDebugMode) {
          print('âŒ Storage clear error: $storageError');
        }
      }

      _user = null;
      _token = null;
      _refreshToken = null;
      _nextStep = null;
      _clearErrors();
      clearTempSignUpData();
      _authState = AuthState.unauthenticated;
      notifyListeners();

      if (kDebugMode) {
        print('âœ… Forced logout completed');
      }
    }
  }

  // Future<void> logout() async {
  //   try {
  //     if (kDebugMode) {
  //       print('=== Logout Started ===');
  //     }

  //     _setAuthState(AuthState.loading);

  //     _tokenManager.stopMonitoring();
  //     await _authService.logout();
  //     await _storageService.clearAuthData();

  //     _user = null;
  //     _token = null;
  //     _refreshToken = null;
  //     _nextStep = null;
  //     _clearErrors();
  //     clearTempSignUpData();

  //     _setAuthState(AuthState.unauthenticated);

  //     if (kDebugMode) {
  //       print('=== Logout Completed ===');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Logout error: $e');
  //     }

  //     _tokenManager.stopMonitoring();
  //     await _storageService.clearAuthData();
  //     _user = null;
  //     _token = null;
  //     _refreshToken = null;
  //     _nextStep = null;
  //     _clearErrors();
  //     clearTempSignUpData();
  //     _setAuthState(AuthState.unauthenticated);
  //   }
  // }

  // ============================================================
  // USER PROFILE
  // ============================================================

  Future<bool> fetchProfile() async {
    try {
      if (kDebugMode) {
        print('=== Fetching User Profile ===');
      }

      _clearErrors();
      final userProfile = await _authService.getProfile();

      _user = userProfile;

      if (_token != null && _refreshToken != null) {
        await _storageService.saveAuthData(
          token: _token!,
          refreshToken: _refreshToken!,
          user: userProfile,
          tokenExpiresIn: 7200,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Fetch Profile Error: $e');
      }
      _setError(NetworkException('Failed to load profile. Please try again.'));
      return false;
    }
  }

  // ============================================================
  // PROFILE PHOTO UPLOAD
  // ============================================================

  Future<bool> uploadProfilePhoto(File photoFile) async {
    try {
      if (kDebugMode) {
        print('=== Uploading Profile Photo ===');
      }

      _isUploadingPhoto = true;
      _clearErrors();
      notifyListeners();

      final uploadResponse = await _authService.uploadProfilePhoto(photoFile);

      if (_user != null) {
        _user = _user!.copyWith(profilePhoto: uploadResponse.profilePhotoUrl);

        if (_token != null && _refreshToken != null) {
          await _storageService.saveAuthData(
            token: _token!,
            refreshToken: _refreshToken!,
            user: _user!,
            tokenExpiresIn: 7200,
          );
        }
      }

      _isUploadingPhoto = false;
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Upload Profile Photo Error: $e');
      }

      _isUploadingPhoto = false;

      if (e is ApiException) {
        _setError(e);
      } else if (e is NetworkException) {
        _setError(e);
      } else {
        _setError(
          NetworkException('Failed to upload photo. Please try again.'),
        );
      }

      return false;
    }
  }

  // ============================================================
  // EMAIL AUTHENTICATION
  // ============================================================

  Future<bool> login({required String email, required String password}) async {
    try {
      final validation = _validateLoginInput(email, password);
      if (validation != null) {
        _setValidationError(validation);
        return false;
      }

      _setAuthState(AuthState.loading);
      _clearErrors();

      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      await _handleAuthSuccess(authResponse);
      _startSessionMonitoring();

      return true;
    } on ValidationException catch (e) {
      _setValidationError(e.errors);
      return false;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected login error: $e');
      }
      _setError(
        NetworkException('An unexpected error occurred. Please try again.'),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String userType,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final validation = _validateSignUpInput(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (validation != null) {
        _setValidationError(validation);
        return false;
      }

      _setAuthState(AuthState.loading);
      _clearErrors();

      final authResponse = await _authService.signUp(
        userType: userType,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      await _handleAuthSuccess(authResponse);
      return true;
    } on ValidationException catch (e) {
      _setValidationError(e.errors);
      return false;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected sign up error: $e');
      }
      _setError(
        NetworkException('An unexpected error occurred. Please try again.'),
      );
      return false;
    }
  }

  // ============================================================
  // SOCIAL AUTHENTICATION
  // ============================================================

  Future<bool> socialSignIn({
    required String provider,
    required String accessToken,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Social Sign In ===');
        print('Provider: $provider');
      }

      _setAuthState(AuthState.loading);
      _clearErrors();

      final authResponse = await _authService.socialSignIn(
        provider: provider.toLowerCase(),
        accessToken: accessToken,
      );

      await _handleAuthSuccess(authResponse);
      _startSessionMonitoring();

      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected social sign in error: $e');
      }
      _setError(
        NetworkException('Failed to sign in with $provider. Please try again.'),
      );
      return false;
    }
  }

  Future<bool> socialSignUp({
    required String provider,
    required String userType,
    required String accessToken,
  }) async {
    try {
      if (kDebugMode) {
        print('=== Social Sign Up ===');
        print('Provider: $provider');
        print('User Type: $userType');
      }

      _setAuthState(AuthState.loading);
      _clearErrors();

      final authResponse = await _authService.socialSignUp(
        provider: provider.toLowerCase(),
        userType: userType,
        accessToken: accessToken,
      );

      await _handleAuthSuccess(authResponse);
      _startSessionMonitoring();

      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected social sign up error: $e');
      }
      _setError(
        NetworkException('Failed to sign up with $provider. Please try again.'),
      );
      return false;
    }
  }

  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    // Save auth data first
    await _storageService.saveAuthData(
      token: authResponse.token,
      refreshToken: authResponse.refreshToken,
      user: authResponse.user,
      tokenExpiresIn: authResponse.tokenExpiresIn ?? 7200,
    );

    // Clear any stale ride state on new login
    await getIt<RidePersistenceService>().clearRideState();

    // Set token for API calls
    _authService.setAuthToken(authResponse.token);

    // Update state
    _user = authResponse.user;
    _token = authResponse.token;
    _refreshToken = authResponse.refreshToken;
    _nextStep = authResponse.nextStep;

    // CRITICAL: Log user type for debugging
    if (kDebugMode) {
      print('=== Auth Success ===');
      print('User Type: ${_user?.userType}');
      print('User Name: ${_user?.firstName} ${_user?.lastName}');
      print('Token: ${_token?.substring(0, 20)}...');
      print('==================');
    }

    _setAuthState(AuthState.authenticated);

    // Fetch fresh profile to ensure we have latest data
    try {
      await fetchProfile();
      if (kDebugMode) {
        print('âœ… Profile refreshed after auth success');
      }
    } catch (e) {
      if (kDebugMode) {
        print('âš ï¸ Failed to refresh profile after auth: $e');
      }
      // Don't fail the login if profile refresh fails
      // User data from authResponse is already saved
    }
  }

  // Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
  //   await _storageService.saveAuthData(
  //     token: authResponse.token,
  //     refreshToken: authResponse.refreshToken,
  //     user: authResponse.user,
  //     tokenExpiresIn: authResponse.tokenExpiresIn ?? 7200,
  //   );

  //   _user = authResponse.user;
  //   _token = authResponse.token;
  //   _refreshToken = authResponse.refreshToken;
  //   _nextStep = authResponse.nextStep;

  //   _setAuthState(AuthState.authenticated);
  // }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Future<bool> sendVerificationEmail({required String email}) async {
    try {
      _setAuthState(AuthState.loading);
      _clearErrors();

      await _authService.sendVerification(email: email);

      _setAuthState(AuthState.unauthenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected send verification error: $e');
      }
      _setError(
        NetworkException('An unexpected error occurred. Please try again.'),
      );
      return false;
    }
  }

  Future<bool> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      _setAuthState(AuthState.loading);
      _clearErrors();

      final verificationResponse = await _authService.verifyEmail(
        email: email,
        verificationCode: verificationCode,
      );

      await _storageService.saveAuthData(
        token: verificationResponse.token,
        refreshToken: verificationResponse.refreshToken,
        user: verificationResponse.user,
        tokenExpiresIn: verificationResponse.tokenExpiresIn,
      );

      _user = verificationResponse.user;
      _token = verificationResponse.token;
      _refreshToken = verificationResponse.refreshToken;
      _nextStep = verificationResponse.nextStep;

      clearTempSignUpData();
      _setAuthState(AuthState.authenticated);
      _startSessionMonitoring();

      return true;
    } catch (e) {
      _setError(
        NetworkException('An unexpected error occurred. Please try again.'),
      );
      return false;
    }
  }

  // ============================================================
  // TEMPORARY SIGN-UP DATA
  // ============================================================

  void storeTempSignUpData({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    _tempEmail = email;
    _tempPassword = password;
    _tempConfirmPassword = confirmPassword;
    notifyListeners();
  }

  void clearTempSignUpData() {
    _tempEmail = null;
    _tempPassword = null;
    _tempConfirmPassword = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      _setAuthState(AuthState.loading);
      _clearErrors();

      final updatedUser = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      _user = updatedUser;
      await _storageService.saveUserData(updatedUser);

      _setAuthState(AuthState.authenticated);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e);
      return false;
    } on NetworkException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      _setError(
        NetworkException('Failed to update profile. Please try again.'),
      );
      return false;
    }
  }

  Future<bool> completeSignUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String userType,
  }) async {
    try {
      if (_tempEmail == null ||
          _tempPassword == null ||
          _tempConfirmPassword == null) {
        _setError(
          ValidationException({
            'general': 'Sign-up session expired. Please start over.',
          }),
        );
        return false;
      }

      _setAuthState(AuthState.loading);
      _clearErrors();

      final authResponse = await _authService.signUp(
        userType: userType,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: _tempEmail!,
        password: _tempPassword!,
        confirmPassword: _tempConfirmPassword!,
      );

      await _handleAuthSuccess(authResponse);

      try {
        await _authService.sendVerification(email: _tempEmail!);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to send verification email: $e');
        }
      }

      return true;
    } catch (e) {
      _setError(
        NetworkException('An unexpected error occurred. Please try again.'),
      );
      return false;
    }
  }

  // ============================================================
  // ERROR MANAGEMENT
  // ============================================================

  void clearErrors() {
    _clearErrors();
    notifyListeners();
  }

  void _setError(Exception error) {
    _authState = AuthState.error;
    _lastError = error;
    _validationErrors = null;
    notifyListeners();
  }

  void _setValidationError(Map<String, String> errors) {
    _authState = AuthState.error;
    _validationErrors = errors;
    _lastError = ValidationException(errors);
    notifyListeners();
  }

  void _clearErrors() {
    _lastError = null;
    _validationErrors = null;
    _nextStep = null;
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  Map<String, String>? _validateLoginInput(String email, String password) {
    final errors = <String, String>{};
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(email.trim())) {
      errors['email'] = 'Please enter a valid email address';
    }
    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (password.length < 6) {
      errors['password'] = 'Password must be at least 6 characters long';
    }
    return errors.isEmpty ? null : errors;
  }

  Map<String, String>? _validateSignUpInput({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};
    if (firstName.trim().isEmpty) {
      errors['firstName'] = 'First name is required';
    }
    if (lastName.trim().isEmpty) errors['lastName'] = 'Last name is required';
    if (phone.trim().isEmpty) errors['phone'] = 'Phone number is required';
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(email.trim())) {
      errors['email'] = 'Please enter a valid email address';
    }
    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (password.length < 6) {
      errors['password'] = 'Password must be at least 6 characters long';
    }
    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }
    return errors.isEmpty ? null : errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  void _setAuthState(AuthState state) {
    _authState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _tokenManager.dispose();
    super.dispose();
  }
}
