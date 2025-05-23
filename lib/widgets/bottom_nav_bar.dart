import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/booking_history_screen.dart'; // ✅ Booking History
import '../screens/membership_card_screen.dart'; // ✅ Membership Card Screen
import '../screens/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({required this.selectedIndex, super.key});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent reloading the same screen

    String route;
    switch (index) {
      case 0:
        route = '/home';
        break;
      case 1:
        route = '/bookings';
        break;
      case 2:
        route = '/membership';
        break;
      case 3:
        route = '/profile';
        break;
      default:
        route = '/home';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: const [
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
          _buildNavItem(context, 1, Icons.calendar_today, "Bookings"),
          _buildNavItem(context, 2, Icons.credit_card, "Membership"),
          _buildNavItem(context, 3, Icons.person, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: isSelected ? 14 : 10,
          horizontal: isSelected ? 30 : 24,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB2D732) : Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 250),
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
