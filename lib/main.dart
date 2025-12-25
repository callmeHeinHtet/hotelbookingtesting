import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/membership_card_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/services_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/edit_personal_info_screen.dart';
import 'screens/edit_payment_methods_screen.dart';
import 'screens/edit_addresses_screen.dart';
import 'screens/edit_documents_screen.dart';
import 'screens/edit_emergency_contacts_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/tab_provider.dart';
import 'providers/membership_provider.dart';
import 'providers/user_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/add_payment_method_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider(create: (_) => MembershipProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => BookingProvider()..initialize()),
        ChangeNotifierProxyProvider<MembershipProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, membershipProvider, userProvider) {
            userProvider!.initializeMembershipProvider(membershipProvider);
            return userProvider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mobile App Prototype',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        // ✅ Always start at SignUpScreen
        initialRoute: '/signup',

        routes: {
          '/signup': (context) => SignUpScreen(), // ✅ Correct initial screen
          '/login': (context) => LoginScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
          '/reset_password': (context) => ResetPasswordScreen(),
          '/home': (context) => WelcomeScreen(),
          '/profile': (context) => ProfileScreen(),
          '/membership': (context) => MembershipCardScreen(),
          '/bookings': (context) => BookingHistoryScreen(),
          '/services': (context) => ServicesScreen(),  // ✅ Correct navigation
          '/settings': (context) => SettingsScreen(),
          '/edit-personal-info': (context) => EditPersonalInfoScreen(),
          '/edit-payment-methods': (context) => const EditPaymentMethodsScreen(),
          '/edit-addresses': (context) => const EditAddressesScreen(),
          '/edit-documents': (context) => const EditDocumentsScreen(),
          '/edit-emergency-contacts': (context) => const EditEmergencyContactsScreen(),
          '/add-payment-method': (context) => const AddPaymentMethodScreen(),
          '/payment': (context) => const AddPaymentMethodScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              );
            case '/add-payment-method':
              return MaterialPageRoute(
                builder: (_) => const AddPaymentMethodScreen(),
              );
            case '/payment':
              // Handle payment route
              return MaterialPageRoute(
                builder: (_) => const AddPaymentMethodScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
