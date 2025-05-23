# Hotel Booking App

A modern Flutter application for hotel bookings with a clean UI and comprehensive feature set.

## Features

### User Authentication
- Sign up and login functionality
- Password recovery
- Profile management

### Profile Management
- Personal information editing
- Profile photo management
- Saved payment methods
- Saved addresses
- Document storage
- Emergency contacts

### Booking Management
- Room browsing and booking
- Booking history
- Check-in/Check-out management
- Invoice generation
- Payment processing

### Membership System
- Tiered membership levels (Bronze, Silver, Gold, Platinum)
- Points system
- Membership benefits tracking
- Digital membership card

### Services
- Room service ordering
- Housekeeping requests
- Laundry service
- Spa and wellness bookings
- Business center services
- Transportation services

### Rewards and Promotions
- Points earning and redemption
- Coupon management
- Special offers
- Seasonal discounts

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Firebase account for backend services

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/hotel_booking.git
```

2. Navigate to the project directory:
```bash
cd hotel_booking
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

### Configuration

1. Firebase Setup:
   - Create a new Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Authentication and Firestore in Firebase Console

2. Environment Variables:
   - Copy `.env.example` to `.env`
   - Fill in your API keys and configuration values

## Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── auth/
│   ├── booking/
│   ├── profile/
│   └── services/
├── providers/
│   ├── user_provider.dart
│   ├── coupon_provider.dart
│   └── membership_provider.dart
├── models/
├── services/
└── utils/
```

## Dependencies

- `firebase_auth`: ^5.5.0 - Firebase authentication
- `firebase_core`: ^3.12.0 - Firebase core functionality
- `provider`: ^6.1.1 - State management
- `shared_preferences`: ^2.2.2 - Local data storage
- `image_picker`: ^1.0.7 - Image selection
- `intl`: ^0.18.1 - Internationalization and formatting
- `share_plus`: ^7.2.1 - Content sharing
- `hive`: ^2.2.3 - Local database

## Features in Development

- [ ] Room availability calendar
- [ ] Real-time chat with hotel staff
- [ ] Multi-language support
- [ ] Virtual room tours
- [ ] Integration with maps for location services
- [ ] Advanced booking analytics
- [ ] Social media sharing
- [ ] Guest reviews and ratings

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who have helped shape this project
