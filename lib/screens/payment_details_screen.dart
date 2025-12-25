import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/booking_provider.dart';
import 'invoice_details_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/payment_service.dart';
import '../services/coupon_service.dart';

class PaymentScreen extends StatefulWidget {
  final String roomTitle;
  final String roomType;
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
    this.roomType = '',
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
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isProcessing = false;
  SavedCard? _selectedSavedCard;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Design constants
  static const Color _primaryGreen = Color(0xFFB2D732);
  static const Color _darkBg = Color(0xFF0A0A0A);
  static const Color _cardBg = Color(0xFF1A1A1A);
  static const Color _borderColor = Color(0xFF2A2A2A);
  static const Color _textGrey = Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _zipController.dispose();
    _animationController.dispose();
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
        // Calculate amounts
        final baseAmount = widget.unitPrice * widget.nights;
        double discountAmount = 0.0;
        if (widget.appliedCoupon != null) {
          discountAmount = baseAmount * (widget.appliedCoupon!.discountPercentage / 100);
        }
        final subtotal = baseAmount - discountAmount;
        final tax = widget.totalAmount - subtotal;

        // Calculate points (1 point for every 100 baht spent)
        final pointsEarned = (widget.totalAmount / 100).floor();

        // Add points to user account
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addPoints(pointsEarned);

        // Create booking in Firestore using BookingProvider
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        final booking = await bookingProvider.createBooking(
          roomTitle: widget.roomTitle,
          roomType: widget.roomType.isNotEmpty ? widget.roomType : widget.roomTitle,
          checkInDate: widget.checkInDate,
          checkOutDate: widget.checkOutDate,
          guests: widget.guests,
          roomPrice: widget.unitPrice,
          subtotal: subtotal,
          tax: tax,
          discountAmount: discountAmount,
          totalAmount: widget.totalAmount,
          appliedCouponCode: widget.appliedCoupon?.code,
          couponDiscountPercentage: widget.appliedCoupon?.discountPercentage,
          imagePath: widget.imagePath,
          transactionId: paymentDetails.transactionId,
          paymentMethod: 'Credit Card',
        );

        if (booking == null) {
          throw Exception('Failed to create booking');
        }

        // Show points earned notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.stars, color: _primaryGreen, size: 20),
                  const SizedBox(width: 12),
                  Text('You earned $pointsEarned points!'),
                ],
              ),
              backgroundColor: _cardBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: _primaryGreen.withOpacity(0.3)),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // If this is a new card, ask user if they want to save it
        if (_selectedSavedCard == null && mounted) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: _cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Save Card',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Would you like to save this card for future use?',
                style: TextStyle(color: _textGrey),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No', style: TextStyle(color: _textGrey)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes', style: TextStyle(color: _primaryGreen)),
                ),
              ],
            ),
          );

          if (shouldSave == true && mounted) {
            final card = SavedCard(
              number: _cardNumberController.text.replaceAll(' ', ''),
              type: 'Visa',
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
            SnackBar(
              content: const Text('Payment processing failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        title: const Text(
          "Payment Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final savedCards = userProvider.savedCards;

          return Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPaymentSummary(),
                        const SizedBox(height: 24),

                        if (savedCards.isNotEmpty) ...[
                          _buildSectionTitle("Saved Cards"),
                          const SizedBox(height: 12),
                          _buildSavedCardsSection(savedCards),
                          const SizedBox(height: 24),
                        ],

                        _buildSectionTitle("Enter Card Details"),
                        const SizedBox(height: 16),
                        _buildCardForm(),
                        const SizedBox(height: 32),
                        _buildPayButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isProcessing) _buildLoadingOverlay(),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: _borderColor,
                    child: Icon(Icons.hotel, color: _textGrey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.roomTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.nights} nights • ${widget.guests} guests',
                      style: TextStyle(color: _textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: _borderColor,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(color: _textGrey, fontSize: 14),
              ),
              Text(
                '฿${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _primaryGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (widget.appliedCoupon != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer, color: _primaryGreen, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.appliedCoupon!.discountPercentage.toInt()}% off applied',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSavedCardsSection(List<SavedCard> savedCards) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: savedCards.length,
        itemBuilder: (context, index) {
          final card = savedCards[index];
          final isSelected = _selectedSavedCard?.number == card.number;
          return _buildSavedCardItem(card, isSelected);
        },
      ),
    );
  }

  Widget _buildSavedCardItem(SavedCard card, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectSavedCard(card),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen : _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _primaryGreen : _borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                'assets/images/visa.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.credit_card,
                  color: _textGrey,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.maskedNumber,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.holderName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.black54 : _textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.black,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _cardHolderController,
          label: "Name on Card",
          icon: Icons.person_outline,
          enabled: _selectedSavedCard == null,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Name is required';
            return null;
          },
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
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
            const SizedBox(width: 14),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: "CVV",
                icon: Icons.lock_outline,
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
        const SizedBox(height: 14),
        _buildTextField(
          controller: _zipController,
          label: "ZIP/Postal Code",
          icon: Icons.location_on_outlined,
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
      ],
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
        color: enabled ? Colors.white : _textGrey,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: _primaryGreen, size: 20),
        filled: true,
        fillColor: enabled ? _cardBg : _borderColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 11),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.black,
          disabledBackgroundColor: _primaryGreen.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          _isProcessing ? 'Processing...' : 'Pay ฿${widget.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Processing your payment...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
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
