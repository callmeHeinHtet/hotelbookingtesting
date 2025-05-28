import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/booking_data.dart';
import '../widgets/bottom_nav_bar.dart';

class BookingHistoryScreen extends StatefulWidget {
  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedStatus = 'Upcoming';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          ),
        ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton('Upcoming'),
                _buildStatusButton('Completed'),
                _buildStatusButton('Cancelled'),
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

  Widget _buildStatusButton(String status) {
    final isSelected = _selectedStatus == status;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFD4E157) : Colors.white,
        foregroundColor: isSelected ? Colors.black : Colors.grey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFFD4E157) : Colors.grey,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Retrieve Bookings Based on Tab
  List<Widget> _getBookingsForTab() {
    List<Map<String, dynamic>> filteredBookings;

    if (_selectedStatus == "Completed") {
      filteredBookings = getBookingsByStatus("Completed");
    } else if (_selectedStatus == "Cancelled") {
      filteredBookings = getBookingsByStatus("Cancelled");
    } else {
      filteredBookings = getBookingsByStatus("Upcoming");
    }

    return filteredBookings
        .map((booking) => _buildBookingCard(booking))
        .toList();
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
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
                child:
                    Text("Cancel Booking", style: TextStyle(color: Colors.red)),
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
