import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/booking_history_screen.dart'; // ✅ Booking History
import '../screens/membership_card_screen.dart'; // ✅ Membership Card Screen
import '../screens/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  BottomNavBar({required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent reloading the same screen

    Widget nextScreen;

    switch (index) {
      case 1:
        nextScreen = BookingHistoryScreen(); // ✅ Open Booking History
        break;

      case 2:
        nextScreen = MembershipCardScreen(
          membershipId: "MAR0002",
          expiryDate: "02/30",
          membershipLevel: "Gold Member",
          membershipPoints: "1234", // ✅ FIXED: Ensure this is a String
          profileImage: "", // ✅ FIXED: Default empty string instead of null
        );
        break;


      case 3:
        nextScreen = ProfileScreen();
        break;

      default:
        nextScreen = WelcomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.home, "Home"),
          _buildNavItem(context, 1, Icons.calendar_today, "Bookings"), // ✅ Updated label
          _buildNavItem(context, 2, Icons.credit_card, "Membership"), // ✅ Opens Membership Card
          _buildNavItem(context, 3, Icons.person, "Profile"),
        ],
      ),
    );
  }

  // ✅ Function to build each navigation item dynamically
  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: isSelected ? 14 : 10,
          horizontal: isSelected ? 30 : 24,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFB2D732) : Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.8,
          duration: Duration(milliseconds: 250),
          child: Icon(
            icon,
            size: isSelected ? 36 : 30,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
