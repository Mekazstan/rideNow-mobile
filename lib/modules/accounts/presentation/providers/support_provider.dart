import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/modules/accounts/data/models/police_models.dart';
import 'package:ridenowappsss/modules/accounts/data/models/support_models.dart';
import 'package:ridenowappsss/modules/accounts/domain/services/support_service.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';

enum SupportState { initial, loading, success, error }

class SupportProvider extends ChangeNotifier {
  final SupportService _supportService = SupportService();

  // ============================================================
  // STATE VARIABLES
  // ============================================================

  SupportState _ambulanceState = SupportState.initial;
  SupportState _policeState = SupportState.initial;
  SupportState _privacyState = SupportState.initial;
  SupportState _faqState = SupportState.initial;
  SupportState _ticketState = SupportState.initial;

  List<EmergencyNumber> _emergencyNumbers = [];
  List<PoliceStation> _policeStations = [];
  List<Faq> _faqs = [];
  List<String> _faqCategories = [];
  String? _selectedCategory;
  Exception? _lastError;

  bool _locationSharingEnabled = false;
  bool _detectiveModeEnabled = false;

  // ============================================================
  // GETTERS
  // ============================================================

  SupportState get ambulanceState => _ambulanceState;
  SupportState get policeState => _policeState;
  SupportState get privacyState => _privacyState;
  SupportState get faqState => _faqState;
  SupportState get ticketState => _ticketState;

  List<EmergencyNumber> get emergencyNumbers => _emergencyNumbers;
  List<PoliceStation> get policeStations => _policeStations;
  List<Faq> get faqs => _faqs;
  List<String> get faqCategories => _faqCategories;
  String? get selectedCategory => _selectedCategory;
  Exception? get lastError => _lastError;

  bool get locationSharingEnabled => _locationSharingEnabled;
  bool get detectiveModeEnabled => _detectiveModeEnabled;

  bool get isLoadingAmbulance => _ambulanceState == SupportState.loading;
  bool get isLoadingPolice => _policeState == SupportState.loading;
  bool get isLoadingPrivacy => _privacyState == SupportState.loading;
  bool get isLoadingPrivacyLocation => _privacyState == SupportState.loading;
  bool get isLoadingFaq => _faqState == SupportState.loading;
  bool get isLoadingTicket => _ticketState == SupportState.loading;

  List<Faq> get filteredFaqs {
    if (_selectedCategory == null || _selectedCategory == 'all') {
      return _faqs;
    }
    return _faqs.where((faq) => faq.category == _selectedCategory).toList();
  }

  String? get errorMessage {
    if (_lastError == null) return null;
    if (_lastError is ApiException) return (_lastError as ApiException).message;
    if (_lastError is NetworkException) {
      return (_lastError as NetworkException).message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // ============================================================
  // AMBULANCE SERVICES
  // ============================================================

  Future<bool> fetchAmbulanceServices() async {
    try {
      _ambulanceState = SupportState.loading;
      _clearErrors();
      notifyListeners();

      if (kDebugMode) {
        print('=== Fetching Ambulance Services ===');
      }

      final response = await _supportService.getAmbulanceServices();
      _emergencyNumbers = response.data.emergencyNumbers;

      _ambulanceState = SupportState.success;
      notifyListeners();

      if (kDebugMode) {
        print('Fetched ${_emergencyNumbers.length} emergency numbers');
      }

      return true;
    } on ApiException catch (e) {
      _setError(e, isAmbulance: true);
      return false;
    } on NetworkException catch (e) {
      _setError(e, isAmbulance: true);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected ambulance services error: $e');
      }
      _setError(
        NetworkException('Failed to load emergency numbers'),
        isAmbulance: true,
      );
      return false;
    }
  }

  // ============================================================
  // POLICE STATIONS
  // ============================================================

  Future<bool> fetchPoliceStations({String? location}) async {
    try {
      _policeState = SupportState.loading;
      _clearErrors();
      notifyListeners();

      if (kDebugMode) {
        print('=== Fetching Police Stations ===');
        print('Location: $location');
      }

      final response = await _supportService.getPoliceStations(
        location: location,
      );
      _policeStations = response.data.stations;

      _policeState = SupportState.success;
      notifyListeners();

      if (kDebugMode) {
        print('Fetched ${_policeStations.length} police stations');
      }

      return true;
    } on ApiException catch (e) {
      _setError(e, isPolice: true);
      return false;
    } on NetworkException catch (e) {
      _setError(e, isPolice: true);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected police stations error: $e');
      }
      _setError(
        NetworkException('Failed to load police stations'),
        isPolice: true,
      );
      return false;
    }
  }

  // ============================================================
  // PRIVACY SETTINGS
  // ============================================================

  Future<bool> updateLocationSharing(bool enabled) async {
    try {
      _privacyState = SupportState.loading;
      _clearErrors();
      notifyListeners();

      if (kDebugMode) {
        print('=== Updating Location Sharing ===');
        print('Enabled: $enabled');
      }

      final response = await _supportService.updateLocationSharing(
        enabled: enabled,
      );

      _locationSharingEnabled = response.data.locationSharingEnabled;
      _detectiveModeEnabled = response.data.detectiveModeEnabled;

      _privacyState = SupportState.success;
      notifyListeners();

      if (kDebugMode) {
        print('Location sharing updated successfully');
      }

      return true;
    } on ApiException catch (e) {
      _setError(e, isPrivacy: true);
      return false;
    } on NetworkException catch (e) {
      _setError(e, isPrivacy: true);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected location sharing error: $e');
      }
      _setError(
        NetworkException('Failed to update location sharing'),
        isPrivacy: true,
      );
      return false;
    }
  }

  Future<bool> updateDetectiveMode(bool enabled) async {
    try {
      _privacyState = SupportState.loading;
      _clearErrors();
      notifyListeners();

      if (kDebugMode) {
        print('=== Updating Detective Mode ===');
        print('Enabled: $enabled');
      }

      final response = await _supportService.updateDetectiveMode(
        enabled: enabled,
      );

      _detectiveModeEnabled = response.data.detectiveModeEnabled;
      _locationSharingEnabled = response.data.locationSharingEnabled;

      _privacyState = SupportState.success;
      notifyListeners();

      if (kDebugMode) {
        print('Detective mode updated successfully');
      }

      return true;
    } on ApiException catch (e) {
      _setError(e, isPrivacy: true);
      return false;
    } on NetworkException catch (e) {
      _setError(e, isPrivacy: true);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected detective mode error: $e');
      }
      _setError(
        NetworkException('Failed to update detective mode'),
        isPrivacy: true,
      );
      return false;
    }
  }

  // ============================================================
  // FAQs
  // ============================================================

  Future<bool> fetchFaqs() async {
    try {
      _faqState = SupportState.loading;
      _clearErrors();
      notifyListeners();

      if (kDebugMode) {
        print('=== Fetching FAQs ===');
      }

      final response = await _supportService.getFaqs(includeCategories: true);
      _faqs = response.faqs;
      _faqCategories = ['all', ...response.categories];

      _faqState = SupportState.success;
      notifyListeners();

      if (kDebugMode) {
        print('Fetched ${_faqs.length} FAQs');
        print('Categories: $_faqCategories');
      }

      return true;
    } on ApiException catch (e) {
      _setError(e, isFaq: true);
      return false;
    } on NetworkException catch (e) {
      _setError(e, isFaq: true);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected FAQs error: $e');
      }
      _setError(NetworkException('Failed to load FAQs'), isFaq: true);
      return false;
    }
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Faq> searchFaqs(String query) {
    if (query.trim().isEmpty) return filteredFaqs;

    final lowerQuery = query.toLowerCase();
    return filteredFaqs.where((faq) {
      return faq.question.toLowerCase().contains(lowerQuery) ||
          faq.answer.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ============================================================
  // SUBMIT TICKET
  // ============================================================

  Future<CreateTicketResponse?> submitTicket({
    required String name,
    required String description,
  }) async {
    try {
      if (name.trim().isEmpty) {
        _setError(
          ValidationException({'name': 'Name is required'}),
          isTicket: true,
        );
        return null;
      }

      if (description.trim().isEmpty) {
        _setError(
          ValidationException({'description': 'Description is required'}),
          isTicket: true,
        );
        return null;
      }

      _ticketState = SupportState.loading;
      _clearErrors();
      notifyListeners();

      if (kDebugMode) {
        print('=== Submitting Ticket ===');
      }

      final response = await _supportService.createTicket(
        name: name,
        description: description,
      );

      _ticketState = SupportState.success;
      notifyListeners();

      if (kDebugMode) {
        print('Ticket submitted: ${response.data.ticketNumber}');
      }

      // Refresh the tickets list so the new ticket shows up
      await fetchUserTickets();

      return response;
    } on ValidationException catch (e) {
      _setError(e, isTicket: true);
      return null;
    } on ApiException catch (e) {
      _setError(e, isTicket: true);
      return null;
    } on NetworkException catch (e) {
      _setError(e, isTicket: true);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected submit ticket error: $e');
      }
      _setError(NetworkException('Failed to submit ticket'), isTicket: true);
      return null;
    }
  }

  // ============================================================
  // ERROR MANAGEMENT
  // ============================================================

  void clearErrors() {
    _clearErrors();
    notifyListeners();
  }

  void _setError(
    Exception error, {
    bool isAmbulance = false,
    bool isPolice = false,
    bool isPrivacy = false,
    bool isFaq = false,
    bool isTicket = false,
  }) {
    if (isAmbulance) _ambulanceState = SupportState.error;
    if (isPolice) _policeState = SupportState.error;
    if (isPrivacy) _privacyState = SupportState.error;
    if (isFaq) _faqState = SupportState.error;
    if (isTicket) _ticketState = SupportState.error;

    _lastError = error;
    notifyListeners();
  }

  void _clearErrors() {
    _lastError = null;
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _ambulanceState = SupportState.initial;
    _policeState = SupportState.initial;
    _privacyState = SupportState.initial;
    _faqState = SupportState.initial;
    _ticketState = SupportState.initial;
    _emergencyNumbers = [];
    _policeStations = [];
    _faqs = [];
    _faqCategories = [];
    _selectedCategory = null;
    _locationSharingEnabled = false;
    _detectiveModeEnabled = false;
    _lastError = null;
    _userTickets = [];
    _ticketsData = null;
    _userTicketsState = SupportState.initial;
    notifyListeners();
  }

  // ============================================================
  // TICKETS LIST STATE
  // ============================================================

  SupportState _userTicketsState = SupportState.initial;
  SupportState get userTicketsState => _userTicketsState;

  List<UserTicket> _userTickets = [];
  List<UserTicket> get userTickets => _userTickets;

  TicketsData? _ticketsData;
  TicketsData? get ticketsData => _ticketsData;

  Future<void> fetchUserTickets() async {
    _userTicketsState = SupportState.loading;
    notifyListeners();

    try {
      final response = await _supportService.getUserTickets();
      if (response.success) {
        _userTickets = response.data.tickets;
        _ticketsData = response.data;
        _userTicketsState = SupportState.success;
      } else {
        _setError(Exception(response.message), isTicket: true);
        _userTicketsState = SupportState.error;
      }
    } catch (e) {
      _setError(e is Exception ? e : Exception(e.toString()), isTicket: true);
      _userTicketsState = SupportState.error;
    } finally {
      notifyListeners();
    }
  }
}
