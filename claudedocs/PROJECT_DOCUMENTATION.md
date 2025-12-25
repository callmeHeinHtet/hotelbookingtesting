# Hotel Booking App - Comprehensive Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture](#architecture)
4. [Directory Structure](#directory-structure)
5. [Core Components](#core-components)
6. [State Management](#state-management)
7. [Services Layer](#services-layer)
8. [Data Models](#data-models)
9. [Screens & UI](#screens--ui)
10. [Firebase Integration](#firebase-integration)
11. [Local Storage](#local-storage)
12. [Security Considerations](#security-considerations)
13. [Known Issues & TODOs](#known-issues--todos)

---

## Project Overview

**Name:** Hotel Booking App
**Version:** 1.0.0+1
**Platform:** Flutter (Cross-platform: Android, iOS, Web, Windows, macOS)
**SDK Requirements:** Flutter >=3.0.0 <4.0.0

A modern Flutter application for hotel room booking with comprehensive features including user authentication, membership management, booking history, payment processing, and rewards/coupon systems.

### Key Features
- **User Authentication**: Firebase-based email/password authentication
- **Profile Management**: Personal info, saved cards, documents, emergency contacts
- **Room Booking**: Browse rooms, select dates, guest count, and checkout
- **Membership System**: 4-tier loyalty program (Bronze, Silver, Gold, Platinum)
- **Points & Rewards**: Earn points on bookings, redeem for benefits
- **Coupon System**: Discount codes with validation and expiry
- **Booking History**: Track past, current, and upcoming reservations

---

## Technology Stack

### Core Framework
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | >=3.0.0 | UI Framework |
| Dart | >=3.0.0 | Programming Language |

### Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_auth` | ^5.5.0 | User authentication |
| `firebase_core` | ^3.12.0 | Firebase initialization |
| `provider` | ^6.1.1 | State management |
| `shared_preferences` | ^2.2.2 | Local key-value storage |
| `hive` | ^2.2.3 | Local NoSQL database |
| `hive_flutter` | ^1.1.0 | Hive Flutter integration |
| `image_picker` | ^1.0.7 | Profile photo selection |
| `intl` | ^0.18.1 | Date/number formatting |
| `share_plus` | ^7.2.1 | Content sharing |
| `table_calendar` | ^3.0.9 | Calendar widget |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## Architecture

The app follows a **Provider-based architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                         UI LAYER                            │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │
│  │ Screens │ │ Widgets │ │  Tabs   │ │  Nav    │           │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘           │
└───────┼──────────┼──────────┼──────────┼───────────────────┘
        │          │          │          │
┌───────┼──────────┼──────────┼──────────┼───────────────────┐
│       ▼          ▼          ▼          ▼                   │
│                    STATE LAYER (Provider)                   │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐     │
│  │ UserProvider  │ │MembershipProv │ │ CouponProvider│     │
│  └───────┬───────┘ └───────┬───────┘ └───────┬───────┘     │
└──────────┼─────────────────┼─────────────────┼─────────────┘
           │                 │                 │
┌──────────┼─────────────────┼─────────────────┼─────────────┐
│          ▼                 ▼                 ▼             │
│                    SERVICE LAYER                           │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐     │
│  │ProfileService │ │MembershipSvc  │ │ CouponService │     │
│  └───────┬───────┘ └───────┬───────┘ └───────┬───────┘     │
└──────────┼─────────────────┼─────────────────┼─────────────┘
           │                 │                 │
┌──────────┼─────────────────┼─────────────────┼─────────────┐
│          ▼                 ▼                 ▼             │
│                    DATA LAYER                              │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐     │
│  │SharedPrefs    │ │ Firebase Auth │ │   Firestore   │     │
│  └───────────────┘ └───────────────┘ └───────────────┘     │
└────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
hotelbookingtesting/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── firebase_options.dart        # Firebase configuration
│   │
│   ├── constants/
│   │   ├── app_constants.dart       # Colors, styles, strings, dimensions
│   │   └── data_constants.dart      # Static service/coupon data
│   │
│   ├── models/
│   │   └── room.dart                # Room data model
│   │
│   ├── providers/
│   │   ├── user_provider.dart       # User state management
│   │   ├── membership_provider.dart # Membership state management
│   │   ├── coupon_provider.dart     # Coupon state management
│   │   └── tab_provider.dart        # Tab navigation state
│   │
│   ├── screens/
│   │   ├── login_screen.dart        # Login UI
│   │   ├── signup_screen.dart       # Registration UI
│   │   ├── forgot_password_screen.dart
│   │   ├── reset_password_screen.dart
│   │   ├── welcome_screen.dart      # Main home screen
│   │   ├── profile_screen.dart      # User profile
│   │   ├── edit_personal_info_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── room_details_screen.dart # Room booking flow
│   │   ├── checkin_screen.dart      # Check-in process
│   │   ├── booking_history_screen.dart
│   │   ├── payment_details_screen.dart
│   │   ├── add_payment_method_screen.dart
│   │   ├── invoice_details_screen.dart
│   │   ├── membership_card_screen.dart
│   │   ├── services_screen.dart     # Hotel services
│   │   └── settings_screen.dart     # App settings
│   │
│   ├── services/
│   │   ├── membership_service.dart  # Membership business logic
│   │   ├── profile_service.dart     # Profile data operations
│   │   ├── payment_service.dart     # Payment processing
│   │   └── coupon_service.dart      # Coupon validation
│   │
│   ├── utils/
│   │   ├── app_constants.dart       # Additional constants
│   │   ├── app_styles.dart          # Text/UI styles
│   │   ├── booking_data.dart        # Booking history storage
│   │   ├── validators.dart          # Input validation
│   │   └── types.dart               # Type definitions
│   │
│   └── widgets/
│       ├── bottom_nav_bar.dart      # Bottom navigation
│       ├── custom_button.dart       # Reusable button
│       ├── custom_text_field.dart   # Reusable text field
│       ├── loading_overlay.dart     # Loading indicator
│       └── profile/
│           ├── personal_info_section.dart
│           ├── saved_info_section.dart
│           ├── statistics_section.dart
│           └── rewards_section.dart
│
├── assets/
│   └── images/                      # Room, coupon, service images
│
├── android/                         # Android platform files
├── ios/                            # iOS platform files (if generated)
│
├── pubspec.yaml                    # Dependencies & assets
├── firebase.json                   # Firebase configuration
├── firestore.rules                 # Firestore security rules
└── firestore.indexes.json          # Firestore indexes
```

---

## Core Components

### Entry Point (`main.dart`)

The app initializes in this order:
1. `WidgetsFlutterBinding.ensureInitialized()` - Flutter binding
2. `Firebase.initializeApp()` - Firebase services
3. `initializeDummyBookings()` - Sample booking data
4. `MultiProvider` setup - State management initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initializeDummyBookings();
  runApp(const MyApp());
}
```

### Provider Chain
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TabProvider()),
    ChangeNotifierProvider(create: (_) => MembershipProvider()..initialize()),
    ChangeNotifierProxyProvider<MembershipProvider, UserProvider>(
      create: (_) => UserProvider(),
      update: (_, membershipProvider, userProvider) {
        userProvider!.initializeMembershipProvider(membershipProvider);
        return userProvider;
      },
    ),
  ],
)
```

### Navigation Routes
| Route | Screen | Description |
|-------|--------|-------------|
| `/signup` | SignUpScreen | Initial screen, registration |
| `/login` | LoginScreen | User login |
| `/forgot_password` | ForgotPasswordScreen | Password recovery |
| `/reset_password` | ResetPasswordScreen | Password reset |
| `/home` | WelcomeScreen | Main dashboard |
| `/profile` | ProfileScreen | User profile |
| `/membership` | MembershipCardScreen | Membership details |
| `/bookings` | BookingHistoryScreen | Booking history |
| `/services` | ServicesScreen | Hotel services |
| `/settings` | SettingsScreen | App settings |
| `/add-payment-method` | AddPaymentMethodScreen | Add card |

---

## State Management

### UserProvider (`providers/user_provider.dart`)

Manages user profile data and synchronizes with MembershipProvider.

**State Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `_name` | String | User's display name |
| `_email` | String | User's email |
| `_phone` | String | User's phone number |
| `_points` | int | Membership points |
| `_membershipLevel` | String | Current tier |
| `_savedCards` | List<SavedCard> | Payment methods |

**Key Methods:**
- `loadUserData()` - Loads from SharedPreferences
- `updateUserInfo()` - Updates and persists user data
- `addPoints(int)` - Adds points via MembershipProvider
- `addCard(SavedCard)` - Saves payment method
- `clearData()` - Logout cleanup

### MembershipProvider (`providers/membership_provider.dart`)

Manages membership tier, points, and benefits.

**Membership Tiers:**
| Tier | Points Required | Key Benefits |
|------|-----------------|--------------|
| Bronze | 0 | Welcome drink, 5% room service discount |
| Silver | 2,000 | Early/late checkout, 10% discount, free breakfast |
| Gold | 5,000 | Guaranteed early/late, 15% discount, airport transfer |
| Platinum | 10,000 | Suite upgrades, 20% discount, spa access, lounge |

**State Properties:**
- `_membershipId` - Unique membership identifier
- `_username` - Member name
- `_points` - Current points balance
- `_stays` - Total stays count
- `_pointsHistory` - Transaction history
- `_currentTier` - MembershipTier enum
- `_profileImagePath` - Profile photo path

### TabProvider (`providers/tab_provider.dart`)

Simple state for welcome screen tabs (Rooms, Services, Coupons).

### CouponProvider (`providers/coupon_provider.dart`)

Manages coupon codes with add/remove/validate operations.

---

## Services Layer

### MembershipService (`services/membership_service.dart`)

**Static Configuration:**
```dart
// Tier Requirements
Bronze:   0 points, 0 stays
Silver:   1,000 points, 3 stays
Gold:     5,000 points, 10 stays
Platinum: 20,000 points, 25 stays

// Points Calculation
Points = BookingAmount / 10  // 1 point per 10 Baht
Points Expiry = 730 days (2 years)
```

**Benefits System:**
| Benefit | Available From |
|---------|----------------|
| Welcome Drink | Bronze |
| Early/Late Check-in | Silver |
| Restaurant Discount (15%) | Silver |
| Room Discount (up to 20%) | Silver |
| Room Upgrades | Gold |
| Lounge Access | Gold |
| Spa Discount (20%) | Gold |
| Free Breakfast | Gold |
| Priority Service | Platinum |

### PaymentService (`services/payment_service.dart`)

Payment processing with validation:

```dart
// Bank Details
Bank: Cimso Bank
Account: Cimso Hotel Co., Ltd
Number: 1234-5678-9012-3456
SWIFT: CIMTHBK

// Validation Methods
- validateCardNumber(String) - Luhn algorithm
- validateExpiryDate(String) - MM/YY format, future date
- validateCVV(String) - 3-4 digits
- validateZipCode(String) - 5 digits
- generateTransactionId() - Timestamp-based
```

### ProfileService (`services/profile_service.dart`)

Profile data management with statistics calculation:

**Data Classes:**
- `UserDocument` - Passport/ID storage
- `SavedPaymentMethod` - Card details
- `EmergencyContact` - Emergency contact info
- `Address` - Home/work addresses
- `SecuritySettings` - 2FA, devices, login history

**Statistics Calculation:**
- Total nights stayed
- Total amount spent
- Favorite room type
- Most visited month
- Average nights per stay

### CouponService (`services/coupon_service.dart`)

Singleton pattern for coupon management:

**Default Coupons:**
| Code | Discount | Description |
|------|----------|-------------|
| WELCOME10 | 10% | First booking discount |
| SUMMER25 | 25% | Summer special (expires 8/31/2024) |
| VIP15 | 15% | VIP customer discount |

---

## Data Models

### Room Model (`models/room.dart`)

```dart
class Room {
  final String id;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final List<String> amenities;
  final List<String> images;
}
```

### SavedCard (in UserProvider)

```dart
class SavedCard {
  final String number;
  final String type;        // Visa, MasterCard, etc.
  final String holderName;
  final String expiryDate;

  String get maskedNumber => '**** **** **** ${number.substring(number.length - 4)}';
}
```

### PointsTransaction (in MembershipService)

```dart
class PointsTransaction {
  final DateTime date;
  final String description;
  final int points;
  final DateTime expiryDate;
}
```

---

## Screens & UI

### Design System

**Primary Colors:**
| Name | Hex | Usage |
|------|-----|-------|
| Primary (Lime) | `#B2D732` | Buttons, highlights, active tabs |
| Black | `#000000` | Headers, text, backgrounds |
| White | `#FFFFFF` | Backgrounds, cards |
| Grey | Material Grey | Inactive states, hints |

**Typography:**
```dart
headerStyle:    fontSize: 22, fontWeight: bold
subheaderStyle: fontSize: 18, fontWeight: bold
bodyStyle:      fontSize: 16
priceStyle:     fontSize: 18, color: green, fontWeight: bold
```

**Dimensions:**
```dart
defaultPadding:      20.0
defaultBorderRadius: 15.0
smallBorderRadius:   8.0
roomImageHeight:     180.0
roomCardWidth:       180.0
minTouchTargetSize:  48.0
```

### Screen Flow

```
SignUp → Login → Welcome (Home)
                    │
    ┌───────────────┼───────────────┬───────────────┐
    ▼               ▼               ▼               ▼
 Rooms Tab      Services Tab    Coupons Tab    Profile
    │                                             │
    ▼                               ┌─────────────┼─────────────┐
Room Details                        ▼             ▼             ▼
    │                           Bookings     Membership     Settings
    ▼                               │             │
Check-in                            ▼             ▼
    │                          Invoice       Member Card
    ▼
Payment → Invoice
```

### Bottom Navigation

| Index | Icon | Label | Screen |
|-------|------|-------|--------|
| 0 | home | Home | WelcomeScreen |
| 1 | book | Bookings | BookingHistoryScreen |
| 2 | card_membership | Membership | MembershipCardScreen |
| 3 | person | Profile | ProfileScreen |

---

## Firebase Integration

### Configuration

**Project ID:** `hotel-booking-3f7bf`

**Platform App IDs:**
| Platform | App ID |
|----------|--------|
| Android | `1:495431379020:android:65613eb5b3971a18cb6ce9` |
| iOS | `1:495431379020:ios:d96a18a43e2538a7cb6ce9` |
| Web | `1:495431379020:web:2bc5d6d49e8a76dacb6ce9` |
| Windows | `1:495431379020:web:966c57e3cea4c1d5cb6ce9` |

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 3, 27);
    }
  }
}
```

**WARNING:** Current rules allow open read/write access until March 27, 2025. Production deployment requires proper security rules.

### Authentication

Uses Firebase Authentication with email/password method:
- `signInWithEmailAndPassword()` - Login
- `createUserWithEmailAndPassword()` - Registration (in SignUpScreen)
- `sendPasswordResetEmail()` - Password recovery

---

## Local Storage

### SharedPreferences Keys

| Key | Type | Purpose |
|-----|------|---------|
| `username` | String | User's display name |
| `name` | String | Alias for username |
| `email` | String | User's email |
| `userEmail` | String | Alias for email |
| `phone` | String | Phone number |
| `membershipId` | String | Membership ID |
| `membershipPoints` | int | Points balance |
| `membership_tier` | String | Current tier |
| `stays` | int | Stay count |
| `profileImagePath` | String | Profile photo path |
| `memberStartDate` | String | Join date (ISO8601) |
| `pointsHistory` | List<String> | Points transactions |
| `cardNumbers` | List<String> | Saved card numbers |
| `cardTypes` | List<String> | Saved card types |
| `cardHolders` | List<String> | Cardholder names |
| `cardExpiries` | List<String> | Card expiry dates |
| `user_coupons` | String | Coupon JSON |
| `twoFactorEnabled` | bool | 2FA status |
| `loginHistory` | List<String> | Login records |
| `connectedDevices` | List<String> | Device list |

---

## Security Considerations

### Current Implementation

1. **Firebase Auth**: Secure authentication via Firebase
2. **Card Validation**: Luhn algorithm for card numbers
3. **Input Validation**: Email, phone, password validators
4. **Password Requirements**: Min 8 chars, letter + number

### Areas for Improvement

1. **Firestore Rules**: Currently open - needs proper ACL
2. **Card Data**: Stored in SharedPreferences (not encrypted)
3. **CVV Storage**: Should never be persisted
4. **2FA**: Implemented UI but not functional
5. **Session Management**: No token expiry handling

### Recommended Security Enhancements

```dart
// Example: Encrypt sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'card_data', value: encryptedCardJson);
```

---

## Known Issues & TODOs

### Code TODOs

1. `main.dart:74-77` - Missing screens:
   - EditPaymentMethodsScreen
   - EditAddressesScreen
   - EditDocumentsScreen
   - EditEmergencyContactsScreen

2. `membership_provider.dart:248-251` - Share membership card not implemented

3. Social login buttons (Facebook, Google, Line) - Not functional

### Technical Debt

1. **Booking Data**: Currently in-memory (`List<Map>`) - needs persistence
2. **Dummy Data**: Hardcoded bookings in `initializeDummyBookings()`
3. **Currency**: Hardcoded to Thai Baht (฿) - needs localization
4. **Images**: All local assets - no remote image handling
5. **Error Handling**: Basic try-catch - needs systematic approach

### Missing Features (from README)

- [ ] Room availability calendar
- [ ] Real-time chat with hotel staff
- [ ] Multi-language support
- [ ] Virtual room tours
- [ ] Map integration for location services
- [ ] Advanced booking analytics
- [ ] Social media sharing
- [ ] Guest reviews and ratings

---

## Development Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## API Reference

### Room Types & Pricing

| Room Type | Price (฿/night) | Image Asset |
|-----------|-----------------|-------------|
| Single Room | 1,000 | `single_room.jpg` |
| Deluxe Room | 2,500 | `deluxe_room.jpg` |
| Superior Room | 4,000 | `superior_room.jpg` |
| Suite Room | 5,000 | `suite_room.jpg` |

### Tax Calculation

```dart
const double taxRate = 0.1; // 10%
final subtotal = roomPrice * nights;
final tax = subtotal * taxRate;
final total = subtotal + tax;
```

---

*Documentation generated: December 2024*
*Last updated: Version 1.0.0+1*
