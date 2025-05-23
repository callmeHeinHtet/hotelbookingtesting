import 'package:flutter/material.dart';

class ServiceData {
  static const List<Map<String, String>> services = [
    {
      'title': 'Exclusive Access to Hotel Amenities',
      'image': 'assets/images/service1.jpg',
    },
    {
      'title': 'Priority Room Booking',
      'image': 'assets/images/service2.jpg',
    },
    {
      'title': 'Luxurious massage',
      'image': 'assets/images/service3.jpg',
    },
    {
      'title': 'Partner Discounts',
      'image': 'assets/images/service4.jpg',
    },
  ];
}

class CouponData {
  static const List<Map<String, dynamic>> coupons = [
    {
      'category': 'Food & Drinks',
      'items': [
        {
          'title': 'Silver Members Voucher',
          'image': 'assets/images/coupon.png',
          'expiry': '1 April 2024',
          'isUsed': false,
        },
        {
          'title': 'Gold Members Voucher',
          'image': 'assets/images/coupon1.png',
          'expiry': '15 May 2024',
          'isUsed': false,
        },
        {
          'title': 'Platinum Members Voucher',
          'image': 'assets/images/coupon2.png',
          'expiry': '30 June 2024',
          'isUsed': false,
        },
      ],
    },
    {
      'category': 'Massages',
      'items': [
        {
          'title': 'Silver Members Voucher',
          'image': 'assets/images/coupon3.png',
          'expiry': '25 December 2024',
          'isUsed': false,
        },
        {
          'title': 'Gold Members Voucher',
          'image': 'assets/images/coupon4.png',
          'expiry': '31 March 2024',
          'isUsed': false,
        },
        {
          'title': 'Platinum Members Voucher',
          'image': 'assets/images/coupon5.png',
          'expiry': '1 May 2024',
          'isUsed': false,
        },
      ],
    },
  ];
} 