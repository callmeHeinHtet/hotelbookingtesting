import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room.dart';
import '../utils/app_constants.dart';
import 'payment_details_screen.dart';

class Coupon {
  final String code;
  final String description;
  final double discountPercentage;

  const Coupon({
    required this.code,
    required this.description,
    required this.discountPercentage,
  });
}

class CheckInScreen extends StatefulWidget {
  final Room room;

  const CheckInScreen({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
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

  DateTime? checkInDate;
  DateTime? checkOutDate;
  double discountAmount = 0;
  double taxAmount = 0;
  double serviceCharge = 0;
  String? appliedCoupon;
  bool isApplyingCoupon = false;
  int _guestCount = 2;

  final List<Coupon> availableCoupons = const [
    Coupon(
      code: 'SAVE10',
      description: '10% off on your booking',
      discountPercentage: 10,
    ),
    Coupon(
      code: 'SPECIAL20',
      description: '20% discount for special occasions',
      discountPercentage: 20,
    ),
    Coupon(
      code: 'WEEKEND15',
      description: '15% off for weekend stays',
      discountPercentage: 15,
    ),
  ];

  int get numberOfNights => checkOutDate != null && checkInDate != null
      ? checkOutDate!.difference(checkInDate!).inDays
      : 0;

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
    _calculateCharges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateCharges() {
    if (numberOfNights > 0) {
      final baseAmount = widget.room.price * numberOfNights;
      setState(() {
        taxAmount = baseAmount * AppConstants.taxRate;
        serviceCharge = baseAmount * 0.1;
      });
    }
  }

  void _applyCoupon(Coupon coupon) {
    setState(() {
      isApplyingCoupon = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isApplyingCoupon = false;
        appliedCoupon = coupon.code;
        discountAmount = widget.room.price *
            numberOfNights *
            (coupon.discountPercentage / 100);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: _primaryGreen, size: 20),
              const SizedBox(width: 12),
              Text('${coupon.code} applied successfully!'),
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
    });
  }

  void _removeCoupon() {
    setState(() {
      appliedCoupon = null;
      discountAmount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: _textGrey, size: 20),
            const SizedBox(width: 12),
            const Text('Coupon removed'),
          ],
        ),
        backgroundColor: _cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _borderColor),
        ),
      ),
    );
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primaryGreen,
              onPrimary: Colors.black,
              surface: _cardBg,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _darkBg,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        checkInDate = picked;
        if (checkOutDate != null && checkOutDate!.isBefore(picked)) {
          checkOutDate = null;
        }
        _calculateCharges();
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: _accentGold, size: 20),
              const SizedBox(width: 12),
              const Text('Please select check-in date first'),
            ],
          ),
          backgroundColor: _cardBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _accentGold.withOpacity(0.3)),
          ),
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: checkInDate!.add(const Duration(days: 1)),
      firstDate: checkInDate!.add(const Duration(days: 1)),
      lastDate: checkInDate!.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primaryGreen,
              onPrimary: Colors.black,
              surface: _cardBg,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _darkBg,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        checkOutDate = picked;
        _calculateCharges();
      });
    }
  }

  void _handlePayment() {
    if (checkInDate == null || checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              const Text('Please select check-in and check-out dates'),
            ],
          ),
          backgroundColor: _cardBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.red),
          ),
        ),
      );
      return;
    }

    final totalAmount = (widget.room.price * numberOfNights) +
        taxAmount +
        serviceCharge -
        discountAmount;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          roomTitle: widget.room.name,
          unitPrice: widget.room.price,
          nights: numberOfNights,
          checkInDate: checkInDate!,
          checkOutDate: checkOutDate!,
          guests: _guestCount,
          totalAmount: totalAmount,
          imagePath: widget.room.images.first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // App Bar with Room Image
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: _darkBg,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardBg.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.room.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _cardBg,
                          child: Icon(Icons.hotel, size: 60, color: _textGrey),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _darkBg.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.room.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.room.description,
                            style: TextStyle(
                              color: _textGrey,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selection Section
                    _buildSectionTitle('Select Dates'),
                    const SizedBox(height: 16),
                    _buildDateSelection(),
                    const SizedBox(height: 24),

                    // Guest Count Section
                    _buildSectionTitle('Guests'),
                    const SizedBox(height: 16),
                    _buildGuestSelector(),
                    const SizedBox(height: 24),

                    // Available Coupons Section
                    if (availableCoupons.isNotEmpty) ...[
                      _buildSectionTitle('Available Coupons'),
                      const SizedBox(height: 16),
                      ...availableCoupons.map((coupon) => _buildCouponCard(coupon)),
                      const SizedBox(height: 24),
                    ],

                    // Price Breakdown Section
                    _buildSectionTitle('Price Details'),
                    const SizedBox(height: 16),
                    _buildPriceBreakdown(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
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

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  icon: Icons.login,
                  label: 'Check-in',
                  date: checkInDate,
                  onTap: _selectCheckInDate,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, color: _primaryGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateButton(
                  icon: Icons.logout,
                  label: 'Check-out',
                  date: checkOutDate,
                  onTap: _selectCheckOutDate,
                ),
              ),
            ],
          ),
          if (numberOfNights > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nights_stay, color: _primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$numberOfNights ${numberOfNights == 1 ? 'Night' : 'Nights'}',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDateButton({
    required IconData icon,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _darkBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? _primaryGreen : _borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _primaryGreen, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date != null
                  ? DateFormat('MMM d, y').format(date)
                  : 'Select date',
              style: TextStyle(
                color: date != null ? Colors.white : _textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.people, color: _primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Number of Guests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Max ${widget.room.capacity} guests',
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: _guestCount > 1 ? _primaryGreen : _textGrey,
                    size: 20,
                  ),
                  onPressed: _guestCount > 1
                      ? () => setState(() => _guestCount--)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$_guestCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: _guestCount < widget.room.capacity
                        ? _primaryGreen
                        : _textGrey,
                    size: 20,
                  ),
                  onPressed: _guestCount < widget.room.capacity
                      ? () => setState(() => _guestCount++)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isApplied = appliedCoupon == coupon.code;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + availableCoupons.indexOf(coupon) * 100),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isApplied ? _primaryGreen.withOpacity(0.1) : _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isApplied ? _primaryGreen : _borderColor,
            width: isApplied ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isApplied
                    ? _primaryGreen.withOpacity(0.2)
                    : _primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_offer,
                color: _primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        coupon.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${coupon.discountPercentage.toInt()}% OFF',
                          style: TextStyle(
                            color: _accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.description,
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: isApplyingCoupon
                  ? null
                  : () {
                      if (isApplied) {
                        _removeCoupon();
                      } else {
                        _applyCoupon(coupon);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApplied ? Colors.red : _primaryGreen,
                foregroundColor: isApplied ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isApplyingCoupon
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(_primaryGreen),
                      ),
                    )
                  : Text(
                      isApplied ? 'Remove' : 'Apply',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final subtotal = widget.room.price * numberOfNights;
    final total = subtotal + taxAmount + serviceCharge - discountAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Room Rate',
            '฿${widget.room.price.toStringAsFixed(0)}/night',
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Number of Nights',
            '$numberOfNights',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: _borderColor, height: 1),
          ),
          _buildPriceRow(
            'Subtotal',
            '฿${subtotal.toStringAsFixed(0)}',
            isBold: true,
          ),
          const SizedBox(height: 12),
          if (appliedCoupon != null) ...[
            _buildPriceRow(
              'Discount ($appliedCoupon)',
              '-฿${discountAmount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
            const SizedBox(height: 12),
          ],
          _buildPriceRow(
            'Taxes (${(AppConstants.taxRate * 100).toInt()}%)',
            '฿${taxAmount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Service Charge (10%)',
            '฿${serviceCharge.toStringAsFixed(0)}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                '฿${total.toStringAsFixed(0)}',
                style: TextStyle(
                  color: _primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? _primaryGreen : _textGrey,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount
                ? _primaryGreen
                : (isBold ? Colors.white : _textGrey),
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final total = (widget.room.price * numberOfNights) +
        taxAmount +
        serviceCharge -
        discountAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    numberOfNights > 0 ? '฿${total.toStringAsFixed(0)}' : '฿0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
