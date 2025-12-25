import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/payment_service.dart';
import 'package:intl/intl.dart';
import '../screens/booking_history_screen.dart';
import '../constants/app_constants.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> bookedRooms;

  const InvoiceDetailsScreen({Key? key, required this.bookedRooms}) : super(key: key);

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Design constants
  static const Color _primaryGreen = Color(0xFFB2D732);
  static const Color _darkBg = Color(0xFF0A0A0A);
  static const Color _cardBg = Color(0xFF1A1A1A);
  static const Color _borderColor = Color(0xFF2A2A2A);
  static const Color _textGrey = Color(0xFF888888);
  static const Color _accentGold = Color(0xFFD4AF37);

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
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.bookedRooms[0];
    final paymentDetails = booking['paymentDetails'];
    final total = booking['totalAmount'] as double;
    final nights = booking['nights'] as int;
    final unitPrice = booking['unitPrice'] as double;
    final baseAmount = unitPrice * nights;
    final appliedCoupon = booking['appliedCoupon'] as Map<String, dynamic>?;

    double subtotal = baseAmount;
    double discountAmount = 0.0;

    if (appliedCoupon != null) {
      final discountPercentage = appliedCoupon['discountPercentage'] as double;
      discountAmount = baseAmount * (discountPercentage / 100);
      subtotal = baseAmount - discountAmount;
    }

    final tax = total - subtotal;

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Invoice",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: _primaryGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info_outline, color: _primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      const Text('Share feature coming soon'),
                    ],
                  ),
                  backgroundColor: _cardBg,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Banner
              _buildSuccessBanner(),
              const SizedBox(height: 24),

              // Invoice Header
              _buildInvoiceHeader(paymentDetails),
              const SizedBox(height: 24),

              // Booking Details
              _buildSectionTitle('Booking Details'),
              const SizedBox(height: 12),
              _buildBookingCard(booking),
              const SizedBox(height: 24),

              // Price Breakdown
              _buildSectionTitle('Price Breakdown'),
              const SizedBox(height: 12),
              _buildPriceBreakdown(
                baseAmount: baseAmount,
                nights: nights,
                discountAmount: discountAmount,
                subtotal: subtotal,
                tax: tax,
                total: total,
                appliedCoupon: appliedCoupon,
              ),
              const SizedBox(height: 24),

              // Payment Details
              _buildSectionTitle('Payment Details'),
              const SizedBox(height: 12),
              _buildPaymentDetailsCard(paymentDetails),
              const SizedBox(height: 24),

              // Bank Details
              _buildSectionTitle('Bank Details'),
              const SizedBox(height: 12),
              _buildBankDetailsCard(booking),
              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryGreen.withOpacity(0.2),
            _accentGold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.black,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your booking has been confirmed',
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader(PaymentDetails paymentDetails) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.hotel, color: _primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cimso Hotel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '123 Main Street\nBangkok, Thailand',
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'INVOICE',
                  style: TextStyle(
                    color: _accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '#${paymentDetails.transactionId}',
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              booking['imagePath'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
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
                  booking['roomTitle'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.nights_stay, color: _primaryGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${booking['nights']} nights',
                      style: TextStyle(color: _textGrey, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, color: _primaryGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${booking['guests']} guests',
                      style: TextStyle(color: _textGrey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: _primaryGreen, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(booking['checkInDate'])} - ${_formatDate(booking['checkOutDate'])}',
                      style: TextStyle(color: _textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown({
    required double baseAmount,
    required int nights,
    required double discountAmount,
    required double subtotal,
    required double tax,
    required double total,
    Map<String, dynamic>? appliedCoupon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildPriceRow('Base Price ($nights nights)', '฿${baseAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          if (appliedCoupon != null) ...[
            _buildPriceRow(
              'Discount (${appliedCoupon['discountPercentage']}% off)',
              '-฿${discountAmount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
            const SizedBox(height: 12),
          ],
          _buildPriceRow('Subtotal', '฿${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Tax (${(AppConstants.taxRate * 100).toStringAsFixed(0)}%)',
            '฿${tax.toStringAsFixed(2)}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryGreen.withOpacity(0.3), _borderColor],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '฿${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (appliedCoupon != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: _primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${appliedCoupon['code']} - ${appliedCoupon['description']}',
                      style: TextStyle(
                        color: _primaryGreen,
                        fontSize: 12,
                      ),
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

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? _primaryGreen : _textGrey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? _primaryGreen : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsCard(PaymentDetails paymentDetails) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.credit_card, 'Card Number',
              _formatCardNumber(paymentDetails.cardNumber)),
          _buildDetailDivider(),
          _buildDetailRow(Icons.person_outline, 'Card Holder',
              paymentDetails.cardHolderName),
          _buildDetailDivider(),
          _buildDetailRow(Icons.calendar_today, 'Expiry Date',
              paymentDetails.expiryDate),
        ],
      ),
    );
  }

  Widget _buildBankDetailsCard(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.account_balance, 'Bank Name', booking['bankName']),
          _buildDetailDivider(),
          _buildDetailRow(Icons.person_outline, 'Account Name', booking['accountName']),
          _buildDetailDivider(),
          _buildDetailRow(Icons.numbers, 'Account Number', booking['accountNumber']),
          _buildDetailDivider(),
          _buildDetailRow(Icons.code, 'Swift Code', booking['swiftCode']),
          _buildDetailDivider(),
          _buildDetailRow(Icons.location_on_outlined, 'Branch', booking['bankBranch']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: _textGrey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailDivider() {
    return Divider(height: 1, color: _borderColor, indent: 54);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.download, color: _primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      const Text('Invoice download started'),
                    ],
                  ),
                  backgroundColor: _cardBg,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _primaryGreen.withOpacity(0.3)),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download, size: 20),
            label: const Text(
              'Download Invoice',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BookingHistoryScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.history, size: 20),
            label: const Text(
              'View Booking History',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryGreen,
              side: BorderSide(color: _primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
