import 'package:flutter/material.dart';

class Coupon {
  final String code;
  final double discountPercentage;
  final DateTime? expiryDate;
  final bool isActive;
  final String? description;

  const Coupon({
    required this.code,
    required this.discountPercentage,
    this.expiryDate,
    this.isActive = true,
    this.description,
  });
}

class CouponService {
  // Singleton instance
  static final CouponService _instance = CouponService._internal();
  factory CouponService() => _instance;
  CouponService._internal();

  // In-memory storage of valid coupons
  final Map<String, Coupon> _coupons = {
    'WELCOME10': Coupon(
      code: 'WELCOME10',
      discountPercentage: 10,
      description: 'Welcome discount - 10% off your first booking',
    ),
    'SUMMER25': Coupon(
      code: 'SUMMER25',
      discountPercentage: 25,
      expiryDate: DateTime(2024, 8, 31),
      description: 'Summer special - 25% off your booking',
    ),
    'VIP15': Coupon(
      code: 'VIP15',
      discountPercentage: 15,
      description: 'VIP discount - 15% off for valued customers',
    ),
  };

  // Validate and get coupon details
  Future<Coupon?> validateCoupon(String code) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final coupon = _coupons[code.toUpperCase()];
    
    if (coupon == null) {
      return null;
    }

    // Check if coupon is active
    if (!coupon.isActive) {
      return null;
    }

    // Check if coupon is expired
    if (coupon.expiryDate != null && coupon.expiryDate!.isBefore(DateTime.now())) {
      return null;
    }

    return coupon;
  }

  // Calculate discounted amount
  double calculateDiscountedAmount(double originalAmount, Coupon coupon) {
    final discountAmount = originalAmount * (coupon.discountPercentage / 100);
    return originalAmount - discountAmount;
  }
} 