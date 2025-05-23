import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CouponProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _coupons = [
    {
      'code': 'WELCOME50',
      'discount': 50,
      'type': 'percentage',
      'description': '50% off on your first booking',
      'validUntil': '2024-12-31',
      'isUsed': false,
    },
    {
      'code': 'SUMMER2024',
      'discount': 100,
      'type': 'fixed',
      'description': '\$100 off on summer bookings',
      'validUntil': '2024-08-31',
      'isUsed': false,
    },
  ];

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get coupons => List.from(_coupons);

  Future<void> loadCoupons() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? couponsJson = prefs.getString('user_coupons');
      if (couponsJson != null) {
        final List<dynamic> decoded = jsonDecode(couponsJson);
        _coupons = decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error loading coupons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCoupon(Map<String, dynamic> coupon) async {
    _coupons.add(coupon);
    await _saveCoupons();
    notifyListeners();
  }

  Future<void> removeCoupon(String code) async {
    _coupons.removeWhere((coupon) => coupon['code'] == code);
    await _saveCoupons();
    notifyListeners();
  }

  Future<void> markCouponAsUsed(String code) async {
    final index = _coupons.indexWhere((coupon) => coupon['code'] == code);
    if (index != -1) {
      _coupons[index]['isUsed'] = true;
      await _saveCoupons();
      notifyListeners();
    }
  }

  bool isCouponValid(String code) {
    final coupon = _coupons.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'isUsed': true, 'validUntil': '2000-01-01'},
    );
    
    if (coupon['isUsed']) return false;
    
    final validUntil = DateTime.parse(coupon['validUntil']);
    return DateTime.now().isBefore(validUntil);
  }

  double calculateDiscount(String code, double amount) {
    final coupon = _coupons.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'discount': 0, 'type': 'fixed'},
    );
    
    if (coupon['type'] == 'percentage') {
      return (amount * coupon['discount'] / 100);
    } else {
      return coupon['discount'].toDouble();
    }
  }

  Future<void> _saveCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_coupons', jsonEncode(_coupons));
    } catch (e) {
      debugPrint('Error saving coupons: $e');
    }
  }
} 