import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/payment_service.dart';
import 'package:intl/intl.dart';
import '../screens/booking_history_screen.dart';
import '../constants/app_constants.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> bookedRooms;

  InvoiceDetailsScreen({Key? key, required this.bookedRooms}) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ' + cardNumber.substring(cardNumber.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    final booking = bookedRooms[0];
    final paymentDetails = booking['paymentDetails'];
    final total = booking['totalAmount'] as double;
    final nights = booking['nights'] as int;
    final unitPrice = booking['unitPrice'] as double;
    final baseAmount = unitPrice * nights;
    final appliedCoupon = booking['appliedCoupon'] as Map<String, dynamic>?;

    // Calculate amounts
    double subtotal = baseAmount;
    double discountAmount = 0.0;

    if (appliedCoupon != null) {
      final discountPercentage = appliedCoupon['discountPercentage'] as double;
      discountAmount = baseAmount * (discountPercentage / 100);
      subtotal = baseAmount - discountAmount;
    }

    final tax = total - subtotal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Invoice Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cimso Hotel",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "123 Main Street\nBangkok, Thailand",
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "INVOICE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "#${paymentDetails.transactionId}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 30),

            // Booking Details
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Booking Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          booking['imagePath'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['roomTitle'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "${booking['nights']} nights, ${booking['guests']} guests",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              "${_formatDate(booking['checkInDate'])} - ${_formatDate(booking['checkOutDate'])}",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Price Breakdown
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price Breakdown",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Base Price (${nights} nights)"),
                      Text("฿${baseAmount.toStringAsFixed(2)}"),
                    ],
                  ),
                  if (appliedCoupon != null) ...[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discount (${appliedCoupon['discountPercentage']}% off)",
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          "-฿${discountAmount.toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal"),
                      Text("฿${subtotal.toStringAsFixed(2)}"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Tax (${(AppConstants.taxRate * 100).toStringAsFixed(0)}%)"),
                      Text("฿${tax.toStringAsFixed(2)}"),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "฿${total.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (appliedCoupon != null) ...[
                    SizedBox(height: 10),
                    Text(
                      "Coupon applied: ${appliedCoupon['code']} - ${appliedCoupon['description']}",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 30),

            // Payment Details
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildPaymentDetail("Card Number",
                      _formatCardNumber(paymentDetails.cardNumber)),
                  _buildPaymentDetail(
                      "Card Holder", paymentDetails.cardHolderName),
                  _buildPaymentDetail("Expiry Date", paymentDetails.expiryDate),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Bank Details
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bank Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildPaymentDetail("Bank Name", booking['bankName']),
                  _buildPaymentDetail("Account Name", booking['accountName']),
                  _buildPaymentDetail(
                      "Account Number", booking['accountNumber']),
                  _buildPaymentDetail("Swift Code", booking['swiftCode']),
                  _buildPaymentDetail("Branch", booking['bankBranch']),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Download Button
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement invoice download
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invoice download started')),
                    );
                  },
                  icon: Icon(Icons.download, color: Colors.black),
                  label: Text(
                    "Download Invoice",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB2D732),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                // Continue Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingHistoryScreen()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.check_circle, color: Colors.black),
                  label: Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB2D732),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildPaymentDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(value),
        ],
      ),
    );
  }
}
