import 'package:flutter/material.dart';
import 'invoice_details_screen.dart'; // ✅ Import InvoiceDetailsScreen
import '../widgets/bottom_nav_bar.dart'; // ✅ Import Bottom Navigation Bar

class PaymentScreen extends StatelessWidget {
  final String roomTitle;
  final double unitPrice;
  final int nights;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final double totalAmount;

  PaymentScreen({
    Key? key,
    required this.roomTitle,
    required this.unitPrice,
    required this.nights,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Payment Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            // ✅ **Payment Amount**
            Text("Payment Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("฿ ${totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),

            SizedBox(height: 20),

            // ✅ **Enter Card Details**
            Text("Enter Card Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            _buildTextField("Name on Card", Icons.person, TextInputType.name),
            SizedBox(height: 12),

            _buildTextField("Card Number", Icons.credit_card, TextInputType.number),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildTextField("Expiry Date (MM/YY)", Icons.date_range, TextInputType.datetime)),
                SizedBox(width: 10),
                Expanded(child: _buildTextField("CVV", Icons.lock, TextInputType.number, obscureText: true)),
              ],
            ),

            SizedBox(height: 12),
            _buildTextField("ZIP/Postal Code", Icons.location_on, TextInputType.number),

            SizedBox(height: 30),

            // ✅ **Pay Button**
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoiceDetailsScreen(bookedRooms: [
                        {
                          "roomTitle": roomTitle,
                          "unitPrice": unitPrice,
                          "nights": nights,
                          "checkInDate": checkInDate,
                          "checkOutDate": checkOutDate,
                          "guests": guests,
                          "totalAmount": totalAmount,
                        }
                      ]),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB2D732), // ✅ Light Green
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Pay",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),

      // ✅ **Bottom Navigation Bar**
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }

  // ✅ **Reusable Styled TextField (Now Text is White)**
  Widget _buildTextField(String hintText, IconData icon, TextInputType keyboardType, {bool obscureText = false}) {
    return TextField(
      style: TextStyle(color: Colors.white, fontSize: 16), // ✅ Input text is now white
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(color: Colors.white), // ✅ Placeholder text is white
        prefixIcon: Icon(icon, color: Color(0xFFB2D732)), // ✅ Light green icon
        filled: true,
        fillColor: Colors.black, // ✅ Black background for input field
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}
