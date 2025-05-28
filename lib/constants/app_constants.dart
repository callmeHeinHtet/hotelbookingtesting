import 'package:flutter/material.dart';

/// Application-wide constant values
class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFFB2D732);
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color greenColor = Colors.green;
  static const Color redAccentColor = Colors.redAccent;

  // Numeric Constants
  static const double taxRate = 0.1;
  static const int minGuests = 1;
  static const int maxGuests = 4;
  static const double defaultPadding = 20.0;
  static const double defaultBorderRadius = 15.0;
  static const double smallBorderRadius = 8.0;

  // Dimensions
  static const double roomImageHeight = 180.0;
  static const double roomCardWidth = 180.0;
  static const double roomCardImageHeight = 100.0;
  static const double minTouchTargetSize = 48.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}

/// Application-wide text styles
class AppStyles {
  static const TextStyle headerStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subheaderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
  );

  static const TextStyle priceStyle = TextStyle(
    fontSize: 18,
    color: AppConstants.greenColor,
    fontWeight: FontWeight.bold,
  );
}

/// Application-wide string constants
class AppStrings {
  // Screen Titles
  static const String checkIn = 'Check-In';
  static const String welcome = 'Welcome';
  static const String discover = 'Discover';
  static const String popularRooms = 'Popular Rooms';
  static const String exclusivelyForMembers = 'Exclusively for Members';

  // Tab Labels
  static const String rooms = 'Rooms';
  static const String services = 'Services';
  static const String coupons = 'Coupons';

  // Category Labels
  static const String foodAndDrinks = 'Food & Drinks';
  static const String massages = 'Massages';

  // Button Labels
  static const String continue_ = 'Continue';
  static const String guests = 'Guests:';

  // Date Selection
  static const String checkInDate = 'Check-In Date';
  static const String checkOutDate = 'Check-Out Date';
  static const String selectStayDuration = 'Select your stay duration:';

  // Booking Summary
  static const String nights = 'Nights:';
  static const String subtotal = 'Subtotal:';
  static const String tax = 'Tax (10%):';
  static const String total = 'Total:';

  // Currency
  static const String currencySymbol = '฿';
  static const String perNight = '/ Night';
}

/// Application-wide dimensions
class AppDimensions {
  static const double defaultPadding = 20.0;
  static const double defaultBorderRadius = 15.0;
  static const double smallBorderRadius = 8.0;
  static const double roomImageHeight = 180.0;
  static const double roomCardWidth = 180.0;
  static const double roomCardImageHeight = 100.0;
  static const double minTouchTargetSize = 48.0;
  static const double tabHeight = 40.0;
  static const double serviceCardHeight = 120.0;
  static const double couponCardHeight = 150.0;
}
