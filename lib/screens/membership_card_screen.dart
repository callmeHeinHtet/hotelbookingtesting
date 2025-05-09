import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav_bar.dart';

class MembershipCardScreen extends StatefulWidget {
  final String membershipId;
  final String expiryDate;
  final String membershipLevel;
  final String membershipPoints;
  final String profileImage;

  MembershipCardScreen({
    required this.membershipId,
    required this.expiryDate,
    required this.membershipLevel,
    required this.membershipPoints,
    required this.profileImage,
  });

  @override
  _MembershipCardScreenState createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen> {
  String _username = "Guest";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedName = prefs.getString("username");
    print("📦 Membership card loaded username: $storedName");

    setState(() {
      _username = storedName ?? "Guest";
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Membership Card", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_username,
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(widget.membershipLevel,
                              style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(widget.membershipId,
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                          Text(widget.expiryDate,
                              style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Image.asset(
                    'assets/images/barcode1.png',
                    width: 250,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildOptionItem("Check Membership Services"),
            _buildOptionItem("Check Your Coupons"),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Membership Points",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(widget.membershipPoints,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildOptionItem(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
