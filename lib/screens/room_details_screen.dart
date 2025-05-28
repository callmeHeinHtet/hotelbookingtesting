import 'package:flutter/material.dart';
import 'checkin_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/room.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomTitle;
  final double roomPrice;
  final String imagePath;

  const RoomDetailScreen({
    Key? key,
    required this.roomTitle,
    required this.roomPrice,
    required this.imagePath,
  }) : super(key: key);

  Room _createRoom() {
    return Room(
      id: '1', // You might want to pass this from where RoomDetailScreen is created
      name: roomTitle,
      description: 'A luxurious room with modern amenities',
      price: roomPrice,
      capacity: 2,
      amenities: [
        'WiFi',
        'TV',
        'AC',
        'Breakfast',
        'King Bed',
        'Non-smoking',
      ],
      images: [imagePath],
    );
  }

  void _handleBookNow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckInScreen(
          room: _createRoom(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            "Room Details",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: const [
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Room Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 5)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(imagePath,
                        width: double.infinity, height: 200, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 20),

                // Room Title & Features
                Text(roomTitle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),

                Row(
                  children: const [
                    Icon(Icons.bed, size: 20),
                    SizedBox(width: 5),
                    Text("1 king bed (2 Adults)",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.aspect_ratio, size: 20),
                    SizedBox(width: 5),
                    Text("Room size: 30 sqm/323 sqft",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.smoke_free, size: 20),
                    SizedBox(width: 5),
                    Text("Non-smoking", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 15),

                // Facilities Section
                const Text("See all room facilities",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(children: [
                      Icon(Icons.check, color: Colors.black),
                      SizedBox(width: 5),
                      Text("Breakfast included")
                    ]),
                    Row(children: [
                      Icon(Icons.check, color: Colors.black),
                      SizedBox(width: 5),
                      Text("Cancellation Policy")
                    ]),
                    Row(children: [
                      Icon(Icons.check, color: Colors.black),
                      SizedBox(width: 5),
                      Text("Book and Pay Now")
                    ]),
                  ],
                ),

                const SizedBox(height: 20),

                // Rewards Section
                const Text("Rewards",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Icon(Icons.stars, color: Colors.black),
                      SizedBox(width: 5),
                      Text("100 Points",
                          style:
                              TextStyle(decoration: TextDecoration.underline)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // BOOK NOW Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _handleBookNow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4E157),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "BOOK NOW >",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
      ),
    );
  }
}
