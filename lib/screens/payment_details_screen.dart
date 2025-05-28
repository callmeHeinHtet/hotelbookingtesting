import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'invoice_details_screen.dart'; // ✅ Import InvoiceDetailsScreen
import '../widgets/bottom_nav_bar.dart'; // ✅ Import Bottom Navigation Bar
import '../services/payment_service.dart';
import '../utils/booking_data.dart';
import '../services/coupon_service.dart';

class PaymentScreen extends StatefulWidget {
  final String roomTitle;
  final double unitPrice;
  final int nights;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final double totalAmount;
  final String imagePath;
  final Coupon? appliedCoupon;

  const PaymentScreen({
    Key? key,
    required this.roomTitle,
    required this.unitPrice,
    required this.nights,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.totalAmount,
    required this.imagePath,
    this.appliedCoupon,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isProcessing = false;
  SavedCard? _selectedSavedCard;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _selectSavedCard(SavedCard card) {
    setState(() {
      if (_selectedSavedCard?.number == card.number) {
        _selectedSavedCard = null;
        _clearForm();
      } else {
        _selectedSavedCard = card;
        _cardNumberController.text = card.number;
        _cardHolderController.text = card.holderName;
        _expiryController.text = card.expiryDate;
      }
    });
  }

  void _clearForm() {
    _cardNumberController.clear();
    _cardHolderController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _zipController.clear();
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

      if (paymentDetails != null && mounted) {
        // Calculate points (1 point for every 100 baht spent)
        final pointsEarned = (widget.totalAmount / 100).floor();
        
        // Add points to user account
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addPoints(pointsEarned);

        // Show points earned notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Congratulations! You earned $pointsEarned points!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }

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

        // If this is a new card, ask user if they want to save it
        if (_selectedSavedCard == null) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Save Card'),
              content: const Text('Would you like to save this card for future use?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );

          if (shouldSave == true && mounted) {
            final card = SavedCard(
              number: _cardNumberController.text.replaceAll(' ', ''),
              type: 'Visa', // You might want to detect card type
              holderName: _cardHolderController.text,
              expiryDate: _expiryController.text,
            );
            await Provider.of<UserProvider>(context, listen: false).addCard(card);
          }
        }

        if (mounted) {
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
                    "totalAmount": widget.totalAmount,
                    "imagePath": widget.imagePath,
                    "paymentDetails": paymentDetails,
                    "bankName": PaymentService.bankName,
                    "accountName": PaymentService.accountName,
                    "accountNumber": PaymentService.accountNumber,
                    "swiftCode": PaymentService.swiftCode,
                    "bankBranch": PaymentService.bankBranch,
                    "appliedCoupon": widget.appliedCoupon != null
                        ? {
                            "code": widget.appliedCoupon!.code,
                            "discountPercentage": widget.appliedCoupon!.discountPercentage,
                            "description": widget.appliedCoupon!.description,
                          }
                        : null,
                  }
                ],
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment processing failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildSavedCardItem(SavedCard card, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectSavedCard(card),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB2D732) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFB2D732) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/visa.png',
              height: 40,
              width: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.maskedNumber,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    card.holderName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Payment Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final savedCards = userProvider.savedCards;
          
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment Amount",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "฿ ${widget.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 30),

                      if (savedCards.isNotEmpty) ...[
                        const Text(
                          "Saved Cards",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: savedCards.length,
                            itemBuilder: (context, index) {
                              final card = savedCards[index];
                              final isSelected = _selectedSavedCard?.number == card.number;
                              return _buildSavedCardItem(card, isSelected);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

                      const Text(
                        "Enter Card Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _cardHolderController,
                        label: "Name on Card",
                        icon: Icons.person,
                        enabled: _selectedSavedCard == null,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        controller: _cardNumberController,
                        label: "Card Number",
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        enabled: _selectedSavedCard == null,
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
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _expiryController,
                              label: "MM/YY",
                              icon: Icons.date_range,
                              keyboardType: TextInputType.number,
                              enabled: _selectedSavedCard == null,
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
                          const SizedBox(width: 15),
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
                      const SizedBox(height: 15),

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
                      const SizedBox(height: 30),

                      Center(
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB2D732),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isProcessing ? "Processing..." : "Pay",
                            style: const TextStyle(
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
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2D732)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFFB2D732)),
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB2D732)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
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
