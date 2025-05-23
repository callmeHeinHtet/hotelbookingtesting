import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'John Doe';
  String _email = 'john.doe@example.com';
  String _phone = '+1 234 567 890';
  String _address = '123 Main St, City';
  String _profilePhotoPath = 'assets/images/profile_photo.jpeg';
  
  // Payment Methods
  List<Map<String, String>> _paymentMethods = [
    {'type': 'Visa', 'number': '****4582'},
    {'type': 'Mastercard', 'number': '****7890'},
  ];

  // Addresses
  List<Map<String, String>> _addresses = [
    {'type': 'Home', 'address': '123 Main St, City'},
    {'type': 'Work', 'address': '456 Office Ave, Business District'},
  ];

  // Documents
  List<Map<String, String>> _documents = [
    {'type': 'Passport', 'expiry': 'Dec 2025'},
    {'type': 'ID Card', 'expiry': 'Jan 2024'},
  ];

  // Emergency Contacts
  List<Map<String, String>> _emergencyContacts = [
    {'name': 'Jane Doe', 'relation': 'Spouse', 'phone': '+1 234 567 890'},
  ];

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get profilePhotoPath => _profilePhotoPath;
  List<Map<String, String>> get paymentMethods => List.from(_paymentMethods);
  List<Map<String, String>> get addresses => List.from(_addresses);
  List<Map<String, String>> get documents => List.from(_documents);
  List<Map<String, String>> get emergencyContacts => List.from(_emergencyContacts);

  // Initialize data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? _name;
    _email = prefs.getString('user_email') ?? _email;
    _phone = prefs.getString('user_phone') ?? _phone;
    _address = prefs.getString('user_address') ?? _address;
    _profilePhotoPath = prefs.getString('user_profile_photo') ?? _profilePhotoPath;
    
    notifyListeners();
  }

  // Update personal information
  Future<void> updatePersonalInfo({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (name != null) {
      _name = name;
      await prefs.setString('user_name', name);
    }
    if (email != null) {
      _email = email;
      await prefs.setString('user_email', email);
    }
    if (phone != null) {
      _phone = phone;
      await prefs.setString('user_phone', phone);
    }
    if (address != null) {
      _address = address;
      await prefs.setString('user_address', address);
    }

    notifyListeners();
  }

  // Update profile photo
  Future<void> updateProfilePhoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    _profilePhotoPath = path;
    await prefs.setString('user_profile_photo', path);
    notifyListeners();
  }

  // Update payment methods
  void updatePaymentMethods(List<Map<String, String>> methods) {
    _paymentMethods = List.from(methods);
    notifyListeners();
  }

  // Update addresses
  void updateAddresses(List<Map<String, String>> addresses) {
    _addresses = List.from(addresses);
    notifyListeners();
  }

  // Update documents
  void updateDocuments(List<Map<String, String>> documents) {
    _documents = List.from(documents);
    notifyListeners();
  }

  // Update emergency contacts
  void updateEmergencyContacts(List<Map<String, String>> contacts) {
    _emergencyContacts = List.from(contacts);
    notifyListeners();
  }
} 