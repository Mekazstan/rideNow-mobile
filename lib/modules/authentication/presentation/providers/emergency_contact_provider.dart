import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';

class EmergencyContactProvider extends ChangeNotifier {
  final List<EmergencyContact> _emergencyContacts = [];
  String _searchQuery = '';

  List<EmergencyContact> get emergencyContacts => _emergencyContacts;

  List<EmergencyContact> get filteredEmergencyContacts {
    if (_searchQuery.isEmpty) {
      return _emergencyContacts;
    }
    return _emergencyContacts.where((contact) {
      return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.phoneNumber.contains(_searchQuery);
    }).toList();
  }

  String get searchQuery => _searchQuery;

  bool get hasEmergencyContacts => _emergencyContacts.isNotEmpty;

  int get emergencyContactsCount => _emergencyContacts.length;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addEmergencyContact(EmergencyContact contact) {
    if (!_emergencyContacts.contains(contact)) {
      _emergencyContacts.add(contact);
      notifyListeners();
    }
  }

  void removeEmergencyContact(String contactId) {
    _emergencyContacts.removeWhere((contact) => contact.id == contactId);
    notifyListeners();
  }

  void clearAllContacts() {
    _emergencyContacts.clear();
    _searchQuery = '';
    notifyListeners();
  }

  bool isContactAdded(String contactId) {
    return _emergencyContacts.any((contact) => contact.id == contactId);
  }
}
