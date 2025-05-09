import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/payment_details_screen.dart';
import 'screens/invoice_details_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/membership_card_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/services_screen.dart';  // ✅ Services Screen Import
import 'screens/coupons_screen.dart';   // ✅ Coupons Screen Import
import 'utils/booking_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDummyBookings();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile App Prototype',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // ✅ Always start at SignUpScreen
      initialRoute: '/signup',

      routes: {
        '/signup': (context) => SignUpScreen(), // ✅ Correct initial screen
        '/login': (context) => LoginScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/membership_card': (context) => MembershipCardScreen(
          membershipId: "MAR0002",
          expiryDate: "02/30",
          membershipLevel: "Gold Member",
          membershipPoints: "1234",
          profileImage: "",
        ),
        '/booking_history': (context) => BookingHistoryScreen(),
        '/services': (context) => ServicesScreen(),  // ✅ Correct navigation
        '/coupons': (context) => CouponsScreen(),    // ✅ Correct navigation
      },
    );
  }
}
