import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // ✅ Import Welcome Screen
import '../widgets/bottom_nav_bar.dart';

class CouponsScreen extends StatefulWidget {
  @override
  _CouponsScreenState createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  int selectedDiscoverIndex = 2; // Set "Coupons" as active tab

  final Color selectedColor = Color(0xFFB2D732); // Light Green
  final Color unselectedColor = Colors.black; // Default Black

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // **HEADER (Black Card with Profile)**
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Andrew Marshall',
                      style: TextStyle(
                        color: selectedColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.white, size: 28),
                    SizedBox(width: 15),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(Icons.person, color: Colors.black, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // **DISCOVER SECTION (Navigation Tabs)**
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // **Discover Buttons**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopNavButton(0, 'Rooms', Icons.hotel),
                    _buildTopNavButton(1, 'Services', Icons.room_service),
                    _buildTopNavButton(2, 'Coupons', Icons.card_giftcard),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // **FOOD & DRINKS COUPONS**
          _buildCouponCategory("Food & Drinks", [
            _buildCouponItem('Food Discount', 'assets/images/coupon.png'),
            _buildCouponItem('Drink Special', 'assets/images/coupon1.png'),
            _buildCouponItem('Meal Combo Deal', 'assets/images/coupon2.png'),
          ]),

          // **SPA & MASSAGE COUPONS**
          _buildCouponCategory("Spa & Massage", [
            _buildCouponItem('Massage Discount', 'assets/images/coupon3.png'),
            _buildCouponItem('Spa Package', 'assets/images/coupon4.png'),
            _buildCouponItem('Luxury Massage', 'assets/images/coupon5.png'),
          ]),

          // **HOTEL & ROOM DISCOUNTS**

        ],
      ),

      // **BOTTOM NAVIGATION BAR**
      bottomNavigationBar: BottomNavBar(selectedIndex: 2),

      // **Floating Chat Button**
      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedColor,
        onPressed: () {
          // Implement chat/help functionality here
        },
        child: Icon(Icons.support_agent, color: Colors.black),
      ),
    );
  }

  // **Top Navigation Buttons**
  Widget _buildTopNavButton(int index, String title, IconData icon) {
    bool isSelected = selectedDiscoverIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDiscoverIndex = index;
        });

        // Navigate to the respective screen
        if (title == "Rooms") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
        } else if (title == "Services") {
          Navigator.pushNamed(context, '/services');
        }
      },
      child: Container(
        width: 100,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: isSelected ? Colors.black : Colors.white),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // **Coupon Category Section (Horizontal Scroll)**
  Widget _buildCouponCategory(String title, List<Widget> coupons) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SizedBox(
            height: 140, // ✅ Fixed height
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: coupons.map((coupon) => Padding(
                padding: EdgeInsets.only(right: 15),
                child: coupon,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // **Coupon Item (Matches Design)**
  Widget _buildCouponItem(String title, String imagePath) {
    return Container(
      width: 200, // ✅ Fixed width for each coupon
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(imagePath, width: 200, height: 90, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
