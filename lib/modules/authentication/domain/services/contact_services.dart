import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';

class ContactService {
  /// Request contacts permission
  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  /// Check if contacts permission is granted
  Future<bool> hasContactsPermission() async {
    return await Permission.contacts.isGranted;
  }

  /// Fetch all device contacts
  Future<List<EmergencyContact>> fetchDeviceContacts() async {
    try {
      final hasPermission = await hasContactsPermission();

      if (!hasPermission) {
        final granted = await requestContactsPermission();
        if (!granted) {
          throw Exception('Contacts permission denied');
        }
      }

      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone, ContactProperty.email},
      );

      return contacts
          .where(
            (contact) =>
                contact.phones.isNotEmpty && (contact.displayName?.isNotEmpty ?? false),
          )
          .map(
            (contact) => EmergencyContact(
              id: contact.id ?? '',
              name: contact.displayName ?? '',
              phone: contact.phones.first.number,
              email:
                  contact.emails.isNotEmpty
                      ? contact.emails.first.address
                      : null,
            ),
          )
          .cast<EmergencyContact>()
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception('Failed to fetch contacts: $e');
    }
  }

  /// Open app settings for manual permission grant
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
