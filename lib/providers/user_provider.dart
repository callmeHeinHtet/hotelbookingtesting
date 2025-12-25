import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'membership_provider.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _email = '';
  String _phone = '';
  int _points = 0;
  String _membershipLevel = 'Bronze';
  List<SavedCard> _savedCards = [];
  List<SavedAddress> _savedAddresses = [];
  List<SavedDocument> _savedDocuments = [];
  List<EmergencyContact> _emergencyContacts = [];
  late MembershipProvider _membershipProvider;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  int get points => _points;
  String get membershipLevel => _membershipLevel;
  List<SavedCard> get savedCards => List.unmodifiable(_savedCards);
  List<SavedAddress> get savedAddresses => List.unmodifiable(_savedAddresses);
  List<SavedDocument> get savedDocuments => List.unmodifiable(_savedDocuments);
  List<EmergencyContact> get emergencyContacts => List.unmodifiable(_emergencyContacts);

  void initializeMembershipProvider(MembershipProvider provider) {
    _membershipProvider = provider;
    _syncWithMembershipProvider();
  }

  void _syncWithMembershipProvider() {
    _points = _membershipProvider.points;
    _membershipLevel = _membershipProvider.tier;
    notifyListeners();
  }

  UserProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // First try to load from 'name', then fallback to 'username'
    _name = prefs.getString('name') ?? prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? prefs.getString('userEmail') ?? '';
    _phone = prefs.getString('phone') ?? '';

    // If we have a username, make sure it's saved in both places
    if (_name.isNotEmpty) {
      await prefs.setString('name', _name);
      await prefs.setString('username', _name);
    }

    // If we have an email, make sure it's saved in both places
    if (_email.isNotEmpty) {
      await prefs.setString('email', _email);
      await prefs.setString('userEmail', _email);
    }

    // Load saved cards
    final cardNumbers = prefs.getStringList('cardNumbers') ?? [];
    final cardTypes = prefs.getStringList('cardTypes') ?? [];
    final cardHolders = prefs.getStringList('cardHolders') ?? [];
    final cardExpiries = prefs.getStringList('cardExpiries') ?? [];

    _savedCards = [];
    for (var i = 0; i < cardNumbers.length; i++) {
      if (i < cardTypes.length &&
          i < cardHolders.length &&
          i < cardExpiries.length) {
        _savedCards.add(SavedCard(
          number: cardNumbers[i],
          type: cardTypes[i],
          holderName: cardHolders[i],
          expiryDate: cardExpiries[i],
        ));
      }
    }

    // Load saved addresses
    final addressesJson = prefs.getStringList('savedAddresses') ?? [];
    _savedAddresses = addressesJson
        .map((json) => SavedAddress.fromJson(jsonDecode(json)))
        .toList();

    // Load saved documents
    final documentsJson = prefs.getStringList('savedDocuments') ?? [];
    _savedDocuments = documentsJson
        .map((json) => SavedDocument.fromJson(jsonDecode(json)))
        .toList();

    // Load emergency contacts
    final contactsJson = prefs.getStringList('emergencyContacts') ?? [];
    _emergencyContacts = contactsJson
        .map((json) => EmergencyContact.fromJson(jsonDecode(json)))
        .toList();

    notifyListeners();
  }

  Future<void> updateUserInfo({
    String? name,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null && name.isNotEmpty) {
      _name = name;
      // Save name in both places
      await prefs.setString('name', name);
      await prefs.setString('username', name);
      // Update username in MembershipProvider
      await _membershipProvider.updateUsername(name);
    }
    if (email != null && email.isNotEmpty) {
      _email = email;
      // Save email in both places
      await prefs.setString('email', email);
      await prefs.setString('userEmail', email);
    }
    if (phone != null && phone.isNotEmpty) {
      _phone = phone;
      await prefs.setString('phone', phone);
    }

    notifyListeners();
  }

  Future<void> addPoints(int amount) async {
    await _membershipProvider.addPoints(amount);
    _syncWithMembershipProvider();
  }

  String _getMembershipLevel(int points) {
    if (points >= 10000) return 'Platinum';
    if (points >= 5000) return 'Gold';
    if (points >= 2000) return 'Silver';
    return 'Bronze';
  }

  // Get points needed for next level
  int getPointsForNextLevel() {
    return _membershipProvider.pointsToNextTier;
  }

  // Get next membership level
  String getNextMembershipLevel() {
    return _membershipProvider.getNextTier();
  }

  Future<void> addCard(SavedCard card) async {
    _savedCards.add(card);
    await _saveCards();
    notifyListeners();
  }

  Future<void> removeCard(String cardNumber) async {
    _savedCards.removeWhere((card) => card.number == cardNumber);
    await _saveCards();
    notifyListeners();
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();

    // Save card data
    await prefs.setStringList(
        'cardNumbers', _savedCards.map((c) => c.number).toList());
    await prefs.setStringList(
        'cardTypes', _savedCards.map((c) => c.type).toList());
    await prefs.setStringList(
        'cardHolders', _savedCards.map((c) => c.holderName).toList());
    await prefs.setStringList(
        'cardExpiries', _savedCards.map((c) => c.expiryDate).toList());
  }

  // Address management
  Future<void> addAddress(SavedAddress address) async {
    // If this is the first address or marked as default, ensure only one default
    if (address.isDefault || _savedAddresses.isEmpty) {
      _savedAddresses = _savedAddresses.map((a) => SavedAddress(
        id: a.id,
        label: a.label,
        addressLine1: a.addressLine1,
        addressLine2: a.addressLine2,
        city: a.city,
        state: a.state,
        postalCode: a.postalCode,
        country: a.country,
        isDefault: false,
      )).toList();
    }
    _savedAddresses.add(address);
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> updateAddress(SavedAddress address) async {
    final index = _savedAddresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isDefault) {
        _savedAddresses = _savedAddresses.map((a) => SavedAddress(
          id: a.id,
          label: a.label,
          addressLine1: a.addressLine1,
          addressLine2: a.addressLine2,
          city: a.city,
          state: a.state,
          postalCode: a.postalCode,
          country: a.country,
          isDefault: false,
        )).toList();
      }
      _savedAddresses[index] = address;
      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> removeAddress(String addressId) async {
    _savedAddresses.removeWhere((a) => a.id == addressId);
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = _savedAddresses
        .map((a) => jsonEncode(a.toJson()))
        .toList();
    await prefs.setStringList('savedAddresses', addressesJson);
  }

  // Document management
  Future<void> addDocument(SavedDocument document) async {
    _savedDocuments.add(document);
    await _saveDocuments();
    notifyListeners();
  }

  Future<void> updateDocument(SavedDocument document) async {
    final index = _savedDocuments.indexWhere((d) => d.id == document.id);
    if (index != -1) {
      _savedDocuments[index] = document;
      await _saveDocuments();
      notifyListeners();
    }
  }

  Future<void> removeDocument(String documentId) async {
    _savedDocuments.removeWhere((d) => d.id == documentId);
    await _saveDocuments();
    notifyListeners();
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = _savedDocuments
        .map((d) => jsonEncode(d.toJson()))
        .toList();
    await prefs.setStringList('savedDocuments', documentsJson);
  }

  // Emergency contact management
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    _emergencyContacts.add(contact);
    await _saveEmergencyContacts();
    notifyListeners();
  }

  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    final index = _emergencyContacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _emergencyContacts[index] = contact;
      await _saveEmergencyContacts();
      notifyListeners();
    }
  }

  Future<void> removeEmergencyContact(String contactId) async {
    _emergencyContacts.removeWhere((c) => c.id == contactId);
    await _saveEmergencyContacts();
    notifyListeners();
  }

  Future<void> _saveEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = _emergencyContacts
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList('emergencyContacts', contactsJson);
  }

  // Clear all user data (for logout)
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();

    // Store the username and email before clearing
    final storedUsername = prefs.getString('username');
    final storedName = prefs.getString('name');
    final storedEmail = prefs.getString('email');
    final storedUserEmail = prefs.getString('userEmail');

    // Store card data before clearing
    final cardNumbers = prefs.getStringList('cardNumbers');
    final cardTypes = prefs.getStringList('cardTypes');
    final cardHolders = prefs.getStringList('cardHolders');
    final cardExpiries = prefs.getStringList('cardExpiries');

    // Clear all data
    await prefs.clear();

    // Restore username and email if they exist
    if (storedUsername != null && storedUsername.isNotEmpty) {
      await prefs.setString('username', storedUsername);
      await prefs.setString('name', storedUsername);
    }
    if (storedEmail != null && storedEmail.isNotEmpty) {
      await prefs.setString('email', storedEmail);
      await prefs.setString('userEmail', storedEmail);
    }

    // Restore card data if it exists
    if (cardNumbers != null)
      await prefs.setStringList('cardNumbers', cardNumbers);
    if (cardTypes != null) await prefs.setStringList('cardTypes', cardTypes);
    if (cardHolders != null)
      await prefs.setStringList('cardHolders', cardHolders);
    if (cardExpiries != null)
      await prefs.setStringList('cardExpiries', cardExpiries);

    // Reset local state but keep cards
    _name = storedUsername ?? '';
    _email = storedEmail ?? '';
    _phone = '';
    _points = 0;
    _membershipLevel = 'Bronze';

    // Clear membership provider data but preserve username
    await _membershipProvider.clearData(preserveUsername: true);

    notifyListeners();
  }

  // Logout method
  Future<void> logout() async {
    await clearData();
  }
}

class SavedCard {
  final String number;
  final String type;
  final String holderName;
  final String expiryDate;

  SavedCard({
    required this.number,
    required this.type,
    required this.holderName,
    required this.expiryDate,
  });

  String get maskedNumber =>
      '**** **** **** ${number.substring(number.length - 4)}';
}

class SavedAddress {
  final String id;
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  SavedAddress({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = [addressLine1];
    if (addressLine2.isNotEmpty) parts.add(addressLine2);
    parts.add('$city, $state $postalCode');
    parts.add(country);
    return parts.join('\n');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'isDefault': isDefault,
  };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    addressLine1: json['addressLine1'] ?? '',
    addressLine2: json['addressLine2'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    postalCode: json['postalCode'] ?? '',
    country: json['country'] ?? '',
    isDefault: json['isDefault'] ?? false,
  );
}

class SavedDocument {
  final String id;
  final String type;
  final String documentNumber;
  final String issuingCountry;
  final DateTime? expiryDate;

  SavedDocument({
    required this.id,
    required this.type,
    required this.documentNumber,
    required this.issuingCountry,
    this.expiryDate,
  });

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  String get maskedNumber {
    if (documentNumber.length <= 4) return documentNumber;
    return '****${documentNumber.substring(documentNumber.length - 4)}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'documentNumber': documentNumber,
    'issuingCountry': issuingCountry,
    'expiryDate': expiryDate?.toIso8601String(),
  };

  factory SavedDocument.fromJson(Map<String, dynamic> json) => SavedDocument(
    id: json['id'] ?? '',
    type: json['type'] ?? '',
    documentNumber: json['documentNumber'] ?? '',
    issuingCountry: json['issuingCountry'] ?? '',
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
  );
}

class EmergencyContact {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String email;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.email = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'email': email,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    relationship: json['relationship'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
  );
}
