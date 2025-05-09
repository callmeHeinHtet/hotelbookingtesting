import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'room_details_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int selectedDiscoverIndex = 0;
  int selectedBottomNavIndex = 0;

  final Color selectedColor = Color(0xFFB2D732);
  final Color unselectedColor = Colors.black;

  String _username = "Guest";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedName = prefs.getString("username");
    print("🧠 Loaded username: $storedName");

    setState(() {
      _username = storedName ?? "Guest";
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                    Text('Welcome', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Text(_username, style: TextStyle(color: selectedColor, fontSize: 18, fontWeight: FontWeight.bold)),
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
          // ...rest of your layout unchanged
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Popular Rooms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 20),
              children: [
                _buildRoomCard('Single Room', '฿ 1000.00', 'assets/images/single_room.jpg', context),
                _buildRoomCard('Deluxe Room', '฿ 2500.00', 'assets/images/deluxe_room.jpg', context),
                _buildRoomCard('Superior Room', '฿ 4000.00', 'assets/images/superior_room.jpg', context),
                _buildRoomCard('Suite Room', '฿ 5000.00', 'assets/images/suite_room.jpg', context),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exclusively for Members', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildMemberOffer('assets/images/discount1.jpg'),
                      _buildMemberOffer('assets/images/discount2.jpg'),
                      _buildMemberOffer('assets/images/discount3.jpg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedColor,
        onPressed: () {},
        child: Icon(Icons.support_agent, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildTopNavButton(int index, String title, IconData icon) {
    bool isSelected = selectedDiscoverIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDiscoverIndex = index;
        });

        if (title == "Services") {
          Navigator.pushNamed(context, '/services');
        } else if (title == "Coupons") {
          Navigator.pushNamed(context, '/coupons');
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
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(String title, String price, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(
          roomTitle: title,
          roomPrice: double.parse(price.replaceAll(RegExp(r'[^0-9.]'), '')),
          imagePath: imagePath,
        )));
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(imagePath, width: 180, height: 100, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(price, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberOffer(String imagePath) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 15),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}
