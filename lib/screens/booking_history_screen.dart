import 'package:flutter/material.dart';
import '../utils/booking_data.dart';
import '../widgets/bottom_nav_bar.dart';

class BookingHistoryScreen extends StatefulWidget {
  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String selectedTab = "Upcoming"; // Default tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Booking History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),

          // Tabs for navigation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTab("Upcoming"),
                _buildTab("Completed"),
                _buildTab("Cancelled"),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Booking List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: _getBookingsForTab(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
    );
  }

  // Tab Builder
  Widget _buildTab(String tabName) {
    bool isSelected = selectedTab == tabName;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabName;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Retrieve Bookings Based on Tab
  List<Widget> _getBookingsForTab() {
    List<Map<String, dynamic>> filteredBookings;

    if (selectedTab == "Completed") {
      filteredBookings = getBookingsByStatus("Completed");
    } else if (selectedTab == "Cancelled") {
      filteredBookings = getBookingsByStatus("Cancelled");
    } else {
      filteredBookings = getBookingsByStatus("Upcoming");
    }

    return filteredBookings.map((booking) => _buildBookingCard(booking)).toList();
  }

  // ✅ Fixed Booking Card UI
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    bool isUpcoming = booking["status"] == "Upcoming";

    // Use imagePath from booking data
    String imagePath = booking["imagePath"] ?? "assets/images/default_room.jpg";

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display Room Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey[300],
                  child: Icon(Icons.error_outline, size: 50),
                );
              },
            ),
          ),

          SizedBox(height: 10),

          // ✅ Booking Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Check-in Date: ${_formatDate(booking["checkInDate"])}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Check-out Date: ${_formatDate(booking["checkOutDate"])}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Room Type: ${booking["roomTitle"] ?? "N/A"}",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "People: ${booking["guests"]}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10),

          // ✅ Show Cancel Button for Upcoming Bookings
          if (isUpcoming)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  _cancelBooking(booking);
                },
                child: Text("Cancel Booking", style: TextStyle(color: Colors.red)),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Cancel Booking Function
  void _cancelBooking(Map<String, dynamic> booking) {
    setState(() {
      updateBookingStatus(bookingHistory.indexOf(booking), "Cancelled");
    });
  }

  // ✅ Format Dates Properly
  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) {
      return "N/A"; // Return default if date is missing
    }
    if (date is String) {
      return date; // Return the date as is if it's already a string
    }
    return "${date.day}/${date.month}/${date.year}"; // Format the date properly
  }
}
