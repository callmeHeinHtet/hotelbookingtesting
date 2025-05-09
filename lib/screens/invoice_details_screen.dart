import 'package:flutter/material.dart';
import '../utils/booking_data.dart';
import '../screens/booking_history_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> bookedRooms;

  InvoiceDetailsScreen({Key? key, required this.bookedRooms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double subtotal = _calculateSubtotal(); // ✅ Subtotal already includes tax from Check-In Screen
    double tax = _calculateTax(); // ✅ Tax already added in Check-In Screen
    double total = subtotal; // ✅ No need to add tax again!

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Invoice Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Hotel Info
            Text("Cimso Hotel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Bangkok, Thailand"),
            Text("10310"),
            SizedBox(height: 10),

            // ✅ Invoice Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Invoice No:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Invoice Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Due Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text("AB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}"), // Randomized Invoice No.
                  Text(_formatDate(DateTime.now())),
                  Text(_formatDate(DateTime.now().add(Duration(days: 4)))),
                ]),
              ],
            ),
            SizedBox(height: 10),

            // ✅ Payment Details
            Text("Pay to: Cimso Bank", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Account Name: Andrew Marshall"),
            Text("Account No: 0123 4567 8901"),
            SizedBox(height: 20),

            // ✅ Invoice Table
            Table(
              border: TableBorder.symmetric(outside: BorderSide(color: Colors.black)),
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2), // ✅ Adjusted width for "nights" text
                3: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow(["Description", "Unit Price", "QTY", "TOTAL"], isHeader: true),
                for (var room in bookedRooms)
                  _buildTableRow([
                    room["roomTitle"],
                    "${room["unitPrice"]} Baht",
                    "${room["nights"]} nights", // ✅ Now displays "2 nights" instead of just "2"
                    room["totalAmount"].toString()
                  ]),
              ],
            ),
            SizedBox(height: 10),

            // ✅ Totals
            _buildSummaryRow("Subtotal (Before Tax)", subtotal - tax), // ✅ Subtotal minus tax
            _buildSummaryRow("Tax (Already Included)", tax), // ✅ Show tax separately
            _buildSummaryRow("Total", total, isBold: true), // ✅ Total is the same, no extra tax

            Spacer(),

            // ✅ Print Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveBookingData();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BookingHistoryScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
    );
  }

  // ✅ Helper to Format Dates
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // ✅ Helper to Build Table Rows
  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            cell,
            style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  // ✅ Helper to Build Summary Rows
  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(amount.toStringAsFixed(2), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // ✅ Use Already Calculated Subtotal
  double _calculateSubtotal() {
    double subtotal = 0;
    for (var room in bookedRooms) {
      subtotal += room["totalAmount"]; // ✅ No extra tax added here
    }
    return subtotal;
  }

  // ✅ Extract Tax from Subtotal
  double _calculateTax() {
    return _calculateSubtotal() / 1.1 * 0.1; // ✅ Reverse tax calculation
  }

  // ✅ Save Booking to Upcoming Section
  void _saveBookingData() {
    for (var room in bookedRooms) {
      bookingHistory.add({
        "roomTitle": room["roomTitle"],
        "checkInDate": room["checkInDate"],
        "checkOutDate": room["checkOutDate"],
        "guests": room["guests"],
        "nights": room["nights"], // ✅ Correctly saving the number of nights
        "totalAmount": room["totalAmount"], // ✅ Correct total amount
        "status": "Upcoming",
      });
    }
  }
}
