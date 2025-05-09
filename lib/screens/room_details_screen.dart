import 'package:flutter/material.dart';
import 'checkin_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomTitle;
  final double roomPrice;
  final String imagePath;

  RoomDetailScreen({
    required this.roomTitle,
    required this.roomPrice,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Welcome", style: TextStyle(color: Colors.white)),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              // ✅ **Room Image**
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(imagePath, width: double.infinity, height: 200, fit: BoxFit.cover),
                ),
              ),

              SizedBox(height: 20),

              // ✅ **Room Title & Features**
              Text(roomTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              Row(
                children: [
                  Icon(Icons.bed, size: 20),
                  SizedBox(width: 5),
                  Text("1 king bed (2 Adults)", style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.aspect_ratio, size: 20),
                  SizedBox(width: 5),
                  Text("Room size: 30 sqm/323 sqft", style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.smoke_free, size: 20),
                  SizedBox(width: 5),
                  Text("Non-smoking", style: TextStyle(fontSize: 16)),
                ],
              ),

              SizedBox(height: 15),

              // ✅ **Facilities Section**
              Text("See all room facilities", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.check, color: Colors.black), SizedBox(width: 5), Text("Breakfast included")]),
                  Row(children: [Icon(Icons.check, color: Colors.black), SizedBox(width: 5), Text("Cancellation Policy")]),
                  Row(children: [Icon(Icons.check, color: Colors.black), SizedBox(width: 5), Text("Book and Pay Now")]),
                ],
              ),

              SizedBox(height: 20),

              // ✅ **Rewards Section**
              Text("Rewards", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.stars, color: Colors.black),
                    SizedBox(width: 5),
                    Text("100 Points", style: TextStyle(decoration: TextDecoration.underline)),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // ✅ **BOOK NOW Button (Aligned Right)**
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // ✅ Navigate to Check-In Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckInScreen(
                          roomTitle: roomTitle,
                          roomPrice: roomPrice,
                          imagePath: imagePath,
                        ),
                      ),
                    );
                  },

                  child: Container(

                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "BOOK NOW >",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }
}
