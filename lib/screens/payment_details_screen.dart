import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'invoice_details_screen.dart'; // ✅ Import InvoiceDetailsScreen
import '../widgets/bottom_nav_bar.dart'; // ✅ Import Bottom Navigation Bar
import '../services/payment_service.dart';
import '../utils/booking_data.dart';

class PaymentScreen extends StatefulWidget {
  final String roomTitle;
  final double unitPrice;
  final int nights;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final double totalAmount;
  final String imagePath;

  PaymentScreen({
    Key? key,
    required this.roomTitle,
    required this.unitPrice,
    required this.nights,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.totalAmount,
    required this.imagePath,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      PaymentDetails? paymentDetails = await PaymentService.processPayment(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolderName: _cardHolderController.text,
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        zipCode: _zipController.text,
      );

      if (paymentDetails != null) {
        // Add booking to history
        addBooking(
          roomTitle: widget.roomTitle,
          checkInDate: widget.checkInDate,
          checkOutDate: widget.checkOutDate,
          guests: widget.guests,
          totalAmount: widget.totalAmount,
          status: "Upcoming",
          imagePath: widget.imagePath,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsScreen(
              bookedRooms: [
                {
                  "roomTitle": widget.roomTitle,
                  "unitPrice": widget.unitPrice,
                  "nights": widget.nights,
                  "checkInDate": widget.checkInDate,
                  "checkOutDate": widget.checkOutDate,
                  "guests": widget.guests,
                  "totalAmount": widget.totalAmount, // This already includes tax from check-in screen
                  "imagePath": widget.imagePath,
                  "paymentDetails": paymentDetails,
                  "bankName": PaymentService.bankName,
                  "accountName": PaymentService.accountName,
                  "accountNumber": PaymentService.accountNumber,
                  "swiftCode": PaymentService.swiftCode,
                  "bankBranch": PaymentService.bankBranch,
                }
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment processing failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Amount",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "฿ ${widget.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 30),

                  Text(
                    "Enter Card Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  _buildTextField(
                    controller: _cardHolderController,
                    label: "Name on Card",
                    icon: Icons.person,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Name is required';
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    controller: _cardNumberController,
                    label: "Card Number",
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CardNumberFormatter(),
                    ],
                    validator: (value) {
                      if (!PaymentService.validateCardNumber(value ?? '')) {
                        return 'Invalid card number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _expiryController,
                          label: "MM/YY",
                          icon: Icons.date_range,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryDateFormatter(),
                          ],
                          validator: (value) {
                            if (!PaymentService.validateExpiryDate(value ?? '')) {
                              return 'Invalid date';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(
                          controller: _cvvController,
                          label: "CVV",
                          icon: Icons.lock,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: (value) {
                            if (!PaymentService.validateCVV(value ?? '')) {
                              return 'Invalid CVV';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    controller: _zipController,
                    label: "ZIP/Postal Code",
                    icon: Icons.location_on,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    validator: (value) {
                      if (!PaymentService.validateZipCode(value ?? '')) {
                        return 'Invalid ZIP code';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB2D732),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isProcessing ? "Processing..." : "Pay",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2D732)),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Color(0xFFB2D732)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFB2D732)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String formatted = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(formatted[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String formatted = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(formatted[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
