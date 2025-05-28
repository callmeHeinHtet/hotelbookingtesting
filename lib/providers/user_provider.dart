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
  late MembershipProvider _membershipProvider;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  int get points => _points;
  String get membershipLevel => _membershipLevel;
  List<SavedCard> get savedCards => List.unmodifiable(_savedCards);

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
