import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';
import 'package:ridenowappsss/modules/community/domain/services/community_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactProvider extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  static const String _cacheKey = 'emergency_contacts_cache';

  List<EmergencyContact> _emergencyContacts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  EmergencyContactProvider() {
    _loadCachedContacts();
  }

  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<EmergencyContact> get filteredEmergencyContacts {
    if (_searchQuery.isEmpty) {
      return _emergencyContacts;
    }
    return _emergencyContacts.where((contact) {
      return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.phone.contains(_searchQuery);
    }).toList();
  }

  String get searchQuery => _searchQuery;
  bool get isSyncing => _isLoading;

  bool get hasEmergencyContacts => _emergencyContacts.isNotEmpty;

  int get emergencyContactsCount => _emergencyContacts.length;

  Future<void> _loadCachedContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        _emergencyContacts = decoded
            .map((json) => EmergencyContact.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached contacts: $e');
    }
  }

  Future<void> _saveContactsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _emergencyContacts.map((contact) => contact.toJson()).toList(),
      );
      await prefs.setString(_cacheKey, encoded);
    } catch (e) {
      debugPrint('Error caching contacts: $e');
    }
  }

  Future<void> fetchEmergencyContacts() async {
    try {
      if (_emergencyContacts.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }

      _error = null;
      final contacts = await _communityService.getContacts();
      _emergencyContacts = contacts;
      await _saveContactsToCache();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addEmergencyContact(EmergencyContact contact) {
    if (!_emergencyContacts.any((ec) => ec.id == contact.id || ec.phone == contact.phone)) {
      _emergencyContacts.add(contact);
      _saveContactsToCache();
      notifyListeners();
    }
  }

  Future<bool> createEmergencyContact({
    required String name,
    required String phone,
    String? email,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final id = await _communityService.createContact(
        name: name,
        phone: phone,
        email: email,
      );

      final newContact = EmergencyContact(
        id: id,
        name: name,
        phone: phone,
        email: email,
      );

      _emergencyContacts.add(newContact);
      await _saveContactsToCache();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  Future<bool> removeEmergencyContact(String contactId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _communityService.deleteContact(contactId: contactId);

      _emergencyContacts.removeWhere((contact) => contact.id == contactId);
      await _saveContactsToCache();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearAllContacts() {
    _emergencyContacts.clear();
    _saveContactsToCache();
    _searchQuery = '';
    notifyListeners();
  }

  bool isContactAdded(String contactId) {
    return _emergencyContacts.any((contact) => contact.id == contactId);
  }
}
