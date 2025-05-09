import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ For Date Formatting
import 'payment_details_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class CheckInScreen extends StatefulWidget {
  final String roomTitle;
  final double roomPrice;
  final String imagePath;

  CheckInScreen({
    required this.roomTitle,
    required this.roomPrice,
    required this.imagePath,
  });

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int guests = 1;
  int nights = 0;
  double totalAmount = 0;
  double taxRate = 0.1; // ✅ 10% Tax
  double taxAmount = 0;
  double finalTotal = 0;

  // ✅ Function to show Date Picker
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    DateTime initialDate = isCheckIn ? DateTime.now() : (checkInDate ?? DateTime.now()).add(Duration(days: 1));
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
          checkOutDate = null; // Reset check-out if check-in changes
        } else {
          checkOutDate = picked;
        }
        _calculateTotalAmount();
      });
    }
  }

  // ✅ Function to Calculate Total Cost with Tax
  void _calculateTotalAmount() {
    if (checkInDate != null && checkOutDate != null) {
      nights = checkOutDate!.difference(checkInDate!).inDays;
      if (nights > 0) {
        totalAmount = widget.roomPrice * nights;
        taxAmount = totalAmount * taxRate;
        finalTotal = totalAmount + taxAmount;

        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Check-In", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // ✅ **Room Image & Details**
            Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(widget.imagePath, width: double.infinity, height: 180, fit: BoxFit.cover),
              ),
            ),

            Text(widget.roomTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("฿ ${widget.roomPrice.toStringAsFixed(2)} / Night", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            // ✅ **Check-In & Check-Out Selection**
            Text("Select your stay duration:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // **Check-In Date Picker**
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checkInDate == null ? "Check-In Date" : DateFormat('dd MMM yyyy').format(checkInDate!),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                // **Check-Out Date Picker**
                GestureDetector(
                  onTap: checkInDate == null ? null : () => _selectDate(context, false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: checkInDate == null ? Colors.grey : Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checkOutDate == null ? "Check-Out Date" : DateFormat('dd MMM yyyy').format(checkOutDate!),
                      style: TextStyle(fontSize: 16, color: checkInDate == null ? Colors.grey : Colors.black),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // ✅ **Guest Selection**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Guests:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      onPressed: guests > 1 ? () => setState(() => guests--) : null,
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    Text("$guests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => setState(() => guests++),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // ✅ **Total Cost Breakdown**
            if (totalAmount > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nights: $nights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("Subtotal: ฿ ${totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  Text("Tax (10%): ฿ ${taxAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.redAccent)),
                  SizedBox(height: 5),
                  Text("Total: ฿ ${finalTotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),

            SizedBox(height: 30),

            // ✅ **Continue Button**
            Center(
              child: ElevatedButton(
                onPressed: (checkInDate != null && checkOutDate != null)
                    ? () {
                  // ✅ Navigate to Payment Screen with Real User Data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        roomTitle: widget.roomTitle,
                        checkInDate: checkInDate!,
                        checkOutDate: checkOutDate!,
                        guests: guests,
                        totalAmount: finalTotal, // ✅ Send Total Including Tax
                        nights: nights,
                        unitPrice: widget.roomPrice,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB2D732),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
    );
  }
}
