import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/booking_data.dart';

class UserDocument {
  final String type; // 'passport' or 'id'
  final String number;
  final DateTime expiryDate;
  final String country;

  const UserDocument({
    required this.type,
    required this.number,
    required this.expiryDate,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'number': number,
    'expiryDate': expiryDate.toIso8601String(),
    'country': country,
  };

  factory UserDocument.fromJson(Map<String, dynamic> json) => UserDocument(
    type: json['type'],
    number: json['number'],
    expiryDate: DateTime.parse(json['expiryDate']),
    country: json['country'],
  );
}

class SavedPaymentMethod {
  final String cardType;
  final String lastFourDigits;
  final String cardHolderName;
  final String expiryDate;

  const SavedPaymentMethod({
    required this.cardType,
    required this.lastFourDigits,
    required this.cardHolderName,
    required this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
    'cardType': cardType,
    'lastFourDigits': lastFourDigits,
    'cardHolderName': cardHolderName,
    'expiryDate': expiryDate,
  };

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) => SavedPaymentMethod(
    cardType: json['cardType'],
    lastFourDigits: json['lastFourDigits'],
    cardHolderName: json['cardHolderName'],
    expiryDate: json['expiryDate'],
  );
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phoneNumber;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'relationship': relationship,
    'phoneNumber': phoneNumber,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    name: json['name'],
    relationship: json['relationship'],
    phoneNumber: json['phoneNumber'],
  );
}

class Address {
  final String type; // 'home' or 'work'
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  const Address({
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'street': street,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    type: json['type'],
    street: json['street'],
    city: json['city'],
    state: json['state'],
    country: json['country'],
    postalCode: json['postalCode'],
  );
}

class SecuritySettings {
  final bool twoFactorEnabled;
  final List<String> connectedDevices;
  final List<Map<String, dynamic>> loginHistory;

  const SecuritySettings({
    required this.twoFactorEnabled,
    required this.connectedDevices,
    required this.loginHistory,
  });

  Map<String, dynamic> toJson() => {
    'twoFactorEnabled': twoFactorEnabled,
    'connectedDevices': connectedDevices,
    'loginHistory': loginHistory,
  };

  factory SecuritySettings.fromJson(Map<String, dynamic> json) => SecuritySettings(
    twoFactorEnabled: json['twoFactorEnabled'] ?? false,
    connectedDevices: List<String>.from(json['connectedDevices'] ?? []),
    loginHistory: List<Map<String, dynamic>>.from(json['loginHistory'] ?? []),
  );
}

class ProfileService {
  static Future<Map<String, dynamic>> getAccountStatistics() async {
    final bookings = getAllBookings();
    
    // Calculate total nights
    int totalNights = 0;
    double totalSpent = 0;
    Map<String, int> roomTypes = {};
    Map<int, int> visitedMonths = {};
    
    for (var booking in bookings) {
      final checkIn = booking['checkInDate'] as DateTime;
      final checkOut = booking['checkOutDate'] as DateTime;
      final nights = checkOut.difference(checkIn).inDays;
      
      totalNights += nights;
      totalSpent += booking['totalAmount'] as double;
      
      // Count room types
      final roomTitle = booking['roomTitle'] as String;
      roomTypes[roomTitle] = (roomTypes[roomTitle] ?? 0) + 1;
      
      // Count visited months
      visitedMonths[checkIn.month] = (visitedMonths[checkIn.month] ?? 0) + 1;
    }
    
    // Find favorite room type
    String favoriteRoomType = '';
    int maxBookings = 0;
    roomTypes.forEach((type, count) {
      if (count > maxBookings) {
        maxBookings = count;
        favoriteRoomType = type;
      }
    });
    
    // Find most visited month
    int mostVisitedMonth = 1;
    int maxVisits = 0;
    visitedMonths.forEach((month, count) {
      if (count > maxVisits) {
        maxVisits = count;
        mostVisitedMonth = month;
      }
    });

    return {
      'totalNights': totalNights,
      'totalSpent': totalSpent,
      'favoriteRoomType': favoriteRoomType,
      'mostVisitedMonth': mostVisitedMonth,
      'totalBookings': bookings.length,
      'averageNightsPerStay': bookings.isEmpty ? 0 : totalNights / bookings.length,
    };
  }

  static Future<void> toggleTwoFactor(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('twoFactorEnabled', enabled);
  }

  static Future<void> addLoginHistory(String device, String location) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('loginHistory') ?? [];
    
    final login = {
      'device': device,
      'location': location,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    history.add(login.toString());
    if (history.length > 10) history.removeAt(0); // Keep only last 10 logins
    
    await prefs.setStringList('loginHistory', history);
  }

  static Future<void> addConnectedDevice(String deviceInfo) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> devices = prefs.getStringList('connectedDevices') ?? [];
    
    if (!devices.contains(deviceInfo)) {
      devices.add(deviceInfo);
      await prefs.setStringList('connectedDevices', devices);
    }
  }

  static Future<void> removeConnectedDevice(String deviceInfo) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> devices = prefs.getStringList('connectedDevices') ?? [];
    
    devices.remove(deviceInfo);
    await prefs.setStringList('connectedDevices', devices);
  }

  static Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    // In a real app, you would also:
    // 1. Call API to delete account from backend
    // 2. Remove authentication tokens
    // 3. Clear any other stored data
    // 4. Log out the user
  }
} 