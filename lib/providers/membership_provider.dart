import 'package:flutter/material.dart';
import '../services/membership_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembershipProvider extends ChangeNotifier {
  String _membershipId = "";
  String _username = "Guest";
  int _points = 0;
  int _stays = 0;
  List<PointsTransaction> _pointsHistory = [];
  MembershipTier _currentTier = MembershipTier.Bronze;
  bool _isLoading = false;
  DateTime _memberStartDate = DateTime.now();
  String _profileImagePath = "";
  String _tier = 'Silver';
  DateTime _joinDate = DateTime(2023, 1, 1);
  DateTime _validUntil = DateTime(2024, 12, 31);

  // Getters
  String get membershipId => _membershipId;
  String get username => _username;
  int get points => _points;
  int get stays => _stays;
  List<PointsTransaction> get pointsHistory => _pointsHistory;
  MembershipTier get currentTier => _currentTier;
  bool get isLoading => _isLoading;
  DateTime get memberStartDate => _memberStartDate;
  String get profileImagePath => _profileImagePath;
  String get tier => _tier;
  DateTime get joinDate => _joinDate;
  DateTime get validUntil => _validUntil;

  // Computed properties
  int get pointsToNextTier {
    final tierList = ['Bronze', 'Silver', 'Gold', 'Platinum'];
    final currentTierIndex = tierList.indexOf(_tier);

    if (currentTierIndex < tierList.length - 1) {
      final nextTier = tierList[currentTierIndex + 1];
      return tierPoints[nextTier]! - _points;
    }

    return 0; // Already at highest tier
  }

  double get progressToNextTier {
    final tierList = ['Bronze', 'Silver', 'Gold', 'Platinum'];
    final currentTierIndex = tierList.indexOf(_tier);

    if (currentTierIndex >= tierList.length - 1)
      return 1.0; // Already at highest tier

    final nextTier = tierList[currentTierIndex + 1];
    final currentTierMinPoints = tierPoints[_tier]!;
    final nextTierMinPoints = tierPoints[nextTier]!;

    final pointsInCurrentTier = _points - currentTierMinPoints;
    final pointsNeededForNextTier = nextTierMinPoints - currentTierMinPoints;

    return pointsInCurrentTier / pointsNeededForNextTier;
  }

  List<MembershipBenefit> get currentBenefits =>
      MembershipService.getBenefitsForTier(_currentTier);

  Color get tierColor => MembershipService.getTierColor(_currentTier);
  String get tierName => MembershipService.getTierName(_currentTier);

  // Benefits for each tier
  Map<String, List<String>> get tierBenefits => {
        'Bronze': [
          'Early check-in when available',
          'Late check-out when available',
          '5% discount on room service',
        ],
        'Silver': [
          'All Bronze benefits',
          'Free breakfast',
          '10% discount on room service',
          'Welcome drink',
        ],
        'Gold': [
          'All Silver benefits',
          'Guaranteed early check-in',
          'Guaranteed late check-out',
          '15% discount on room service',
          'Free airport transfer',
        ],
        'Platinum': [
          'All Gold benefits',
          'Suite upgrade when available',
          '20% discount on room service',
          'Access to executive lounge',
          'Free spa access',
        ],
      };

  // Points needed for each tier
  Map<String, int> get tierPoints => {
        'Bronze': 0,
        'Silver': 2000,
        'Gold': 5000,
        'Platinum': 10000,
      };

  // Initialize membership data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _membershipId = prefs.getString('membershipId') ??
          "MEM${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // Try to get username from both places
      String? username = prefs.getString('username');
      if (username == null || username.isEmpty) {
        username = prefs.getString('name');
      }

      // Only set username if we have a valid one
      if (username != null && username.isNotEmpty && username != 'Guest User') {
        _username = username;
        // Ensure username is saved in both places
        await prefs.setString('username', username);
        await prefs.setString('name', username);
      }

      _points = prefs.getInt('membershipPoints') ?? 0;
      _stays = prefs.getInt('stays') ?? 0;
      _profileImagePath = prefs.getString('profileImagePath') ?? "";

      // Load member start date
      String? startDateStr = prefs.getString('memberStartDate');
      _memberStartDate =
          startDateStr != null ? DateTime.parse(startDateStr) : DateTime.now();

      // Load points history
      final historyJson = prefs.getStringList('pointsHistory') ?? [];
      _pointsHistory = historyJson.map((json) {
        final parts = json.split('|');
        return PointsTransaction(
          date: DateTime.parse(parts[0]),
          description: parts[1],
          points: int.parse(parts[2]),
          expiryDate: DateTime.parse(parts[3]),
        );
      }).toList();

      // Set initial tier based on points
      _tier = 'Bronze';
      for (var entry in tierPoints.entries) {
        if (_points >= entry.value) {
          _tier = entry.key;
        }
      }

      // Update current tier enum
      switch (_tier.toLowerCase()) {
        case 'silver':
          _currentTier = MembershipTier.Silver;
          break;
        case 'gold':
          _currentTier = MembershipTier.Gold;
          break;
        case 'platinum':
          _currentTier = MembershipTier.Platinum;
          break;
        default:
          _currentTier = MembershipTier.Bronze;
      }

      // Load join date and valid until
      final joinDateStr = prefs.getString('membership_join_date');
      if (joinDateStr != null) {
        _joinDate = DateTime.parse(joinDateStr);
      }

      final validUntilStr = prefs.getString('membership_valid_until');
      if (validUntilStr != null) {
        _validUntil = DateTime.parse(validUntilStr);
      }

      // Save initial data if not exists
      if (!prefs.containsKey('membershipId')) {
        await prefs.setString('membershipId', _membershipId);
        await prefs.setString(
            'memberStartDate', _memberStartDate.toIso8601String());
        await prefs.setString('membership_tier', _tier);
      }
    } catch (e) {
      debugPrint('Error initializing membership: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String imagePath) async {
    _profileImagePath = imagePath;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', imagePath);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving profile image path: $e');
    }
  }

  // Add points from a booking
  Future<void> addBookingPoints(
      double amount, String bookingDescription) async {
    final points = MembershipService.calculatePointsForBooking(amount);
    final transaction = PointsTransaction(
      date: DateTime.now(),
      description: bookingDescription,
      points: points,
      expiryDate: MembershipService.calculatePointsExpiry(DateTime.now()),
    );

    _points += points;
    _stays += 1;
    _pointsHistory.add(transaction);
    _currentTier = MembershipService.getTierFromPoints(_points, _stays);

    // Save to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('membershipPoints', _points);
      await prefs.setInt('stays', _stays);

      final historyJson = _pointsHistory
          .map((t) =>
              '${t.date.toIso8601String()}|${t.description}|${t.points}|${t.expiryDate.toIso8601String()}')
          .toList();
      await prefs.setStringList('pointsHistory', historyJson);
    } catch (e) {
      debugPrint('Error saving membership data: $e');
    }

    notifyListeners();
  }

  // Share membership card
  Future<void> shareMembershipCard() async {
    // TODO: Implement sharing functionality
    // This will be implemented when we update the UI
  }

  // Reset points that have expired
  Future<void> checkExpiredPoints() async {
    final now = DateTime.now();
    int expiredPoints = 0;

    _pointsHistory = _pointsHistory.where((transaction) {
      if (transaction.expiryDate.isBefore(now)) {
        expiredPoints += transaction.points;
        return false;
      }
      return true;
    }).toList();

    if (expiredPoints > 0) {
      _points -= expiredPoints;
      _currentTier = MembershipService.getTierFromPoints(_points, _stays);

      // Save updated points
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('membershipPoints', _points);

        final historyJson = _pointsHistory
            .map((t) =>
                '${t.date.toIso8601String()}|${t.description}|${t.points}|${t.expiryDate.toIso8601String()}')
            .toList();
        await prefs.setStringList('pointsHistory', historyJson);
      } catch (e) {
        debugPrint('Error saving membership data: $e');
      }

      notifyListeners();
    }
  }

  Future<void> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    _points += points;
    await prefs.setInt('membershipPoints', _points);

    // Update tier based on points
    String newTier = 'Bronze';
    for (var entry in tierPoints.entries) {
      if (_points >= entry.value) {
        newTier = entry.key;
      }
    }

    if (_tier != newTier) {
      _tier = newTier;
      await prefs.setString('membership_tier', _tier);

      // Update current tier enum
      switch (_tier.toLowerCase()) {
        case 'silver':
          _currentTier = MembershipTier.Silver;
          break;
        case 'gold':
          _currentTier = MembershipTier.Gold;
          break;
        case 'platinum':
          _currentTier = MembershipTier.Platinum;
          break;
        default:
          _currentTier = MembershipTier.Bronze;
      }
    }

    notifyListeners();
  }

  Future<void> usePoints(int points) async {
    if (_points >= points) {
      final prefs = await SharedPreferences.getInstance();
      _points -= points;
      await prefs.setInt('membership_points', _points);

      // Check for tier downgrade
      String newTier = 'Bronze';
      for (var entry in tierPoints.entries) {
        if (_points >= entry.value) {
          newTier = entry.key;
        }
      }
      if (newTier != _tier) {
        _tier = newTier;
        await prefs.setString('membership_tier', _tier);
      }

      notifyListeners();
    }
  }

  List<String> getCurrentTierBenefits() {
    return tierBenefits[_tier] ?? [];
  }

  String getNextTier() {
    final tierList = ['Bronze', 'Silver', 'Gold', 'Platinum'];
    final currentTierIndex = tierList.indexOf(_tier);

    if (currentTierIndex < tierList.length - 1) {
      return tierList[currentTierIndex + 1];
    }

    return _tier; // Already at highest tier
  }

  bool isMembershipValid() {
    return DateTime.now().isBefore(_validUntil);
  }

  Future<void> updateUsername(String newUsername) async {
    _username = newUsername;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', newUsername);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating username: $e');
    }
  }

  Future<void> clearData({bool preserveUsername = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Store username if we need to preserve it
    final storedUsername = preserveUsername ? _username : null;

    await prefs.clear();
    _membershipId = "";
    _username = preserveUsername ? storedUsername! : "Guest";
    _points = 0;
    _stays = 0;
    _pointsHistory = [];
    _currentTier = MembershipTier.Bronze;
    _profileImagePath = "";
    _tier = 'Bronze';
    _joinDate = DateTime.now();
    _validUntil = _joinDate.add(const Duration(days: 365));

    // Restore username in SharedPreferences if preserving
    if (preserveUsername && storedUsername != null) {
      await prefs.setString('username', storedUsername);
    }

    notifyListeners();
  }
}
