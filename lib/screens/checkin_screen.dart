import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/room.dart';
import '../utils/app_constants.dart';
import '../utils/app_styles.dart';
import 'payment_details_screen.dart';

// Add available coupons
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

class _CheckInScreenState extends State<CheckInScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  double discountAmount = 0;
  double taxAmount = 0;
  double serviceCharge = 0;
  String? appliedCoupon;
  bool isApplyingCoupon = false;

  // List of available coupons
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
    _calculateCharges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _calculateCharges() {
    if (numberOfNights > 0) {
      final baseAmount = widget.room.price * numberOfNights;
      setState(() {
        taxAmount = baseAmount * AppConstants.taxRate;
        serviceCharge = baseAmount * 0.1; // 10% service charge
      });
    }
  }

  void _applyCoupon(Coupon coupon) {
    setState(() {
      isApplyingCoupon = true;
    });

    // Simulate coupon validation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isApplyingCoupon = false;
        appliedCoupon = coupon.code;
        discountAmount = widget.room.price *
            numberOfNights *
            (coupon.discountPercentage / 100);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${coupon.code} applied successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    });
  }

  void _removeCoupon() {
    setState(() {
      appliedCoupon = null;
      discountAmount = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coupon removed'),
          backgroundColor: Colors.black,
        ),
      );
    });
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
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
    if (checkInDate == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: checkInDate!.add(const Duration(days: 1)),
      firstDate: checkInDate!.add(const Duration(days: 1)),
      lastDate: checkInDate!.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4E157),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
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
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: Colors.black,
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
          guests: widget.room.capacity,
          totalAmount: totalAmount,
          imagePath: widget.room.images.first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Check-in', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room image and details
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(widget.room.images.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.room.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.room.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),

                      // Date Selection
                      const Text(
                        'Select Dates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectCheckInDate,
                              icon: const Icon(Icons.calendar_today,
                                  color: Colors.black),
                              label: Text(
                                checkInDate != null
                                    ? DateFormat('MMM d, y')
                                        .format(checkInDate!)
                                    : 'Check-in',
                                style: const TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4E157),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectCheckOutDate,
                              icon: const Icon(Icons.calendar_today,
                                  color: Colors.black),
                              label: Text(
                                checkOutDate != null
                                    ? DateFormat('MMM d, y')
                                        .format(checkOutDate!)
                                    : 'Check-out',
                                style: const TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4E157),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Coupon Section
                      if (availableCoupons.isNotEmpty) ...[
                        const Text(
                          'Available Coupons',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...availableCoupons
                            .map((coupon) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: appliedCoupon == coupon.code
                                        ? const Color(0xFFD4E157)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer,
                                        color: appliedCoupon == coupon.code
                                            ? Colors.black
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              coupon.code,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    appliedCoupon == coupon.code
                                                        ? Colors.black
                                                        : Colors.grey[800],
                                              ),
                                            ),
                                            Text(
                                              coupon.description,
                                              style: TextStyle(
                                                color:
                                                    appliedCoupon == coupon.code
                                                        ? Colors.black
                                                        : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (appliedCoupon == coupon.code) {
                                            _removeCoupon();
                                          } else {
                                            _applyCoupon(coupon);
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              appliedCoupon == coupon.code
                                                  ? Colors.black
                                                  : const Color(0xFFD4E157),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          appliedCoupon == coupon.code
                                              ? 'Remove'
                                              : 'Apply',
                                          style: TextStyle(
                                            color: appliedCoupon == coupon.code
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                      const SizedBox(height: 24),

                      // Price Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPriceRow(
                              'Room Rate (per night)',
                              widget.room.price,
                            ),
                            _buildPriceRow(
                              'Number of Nights',
                              numberOfNights.toDouble(),
                              isNumber: true,
                            ),
                            const Divider(),
                            _buildPriceRow(
                              'Subtotal',
                              widget.room.price * numberOfNights,
                              isBold: true,
                            ),
                            if (appliedCoupon != null)
                              _buildPriceRow(
                                'Discount ($appliedCoupon)',
                                -discountAmount,
                                isDiscount: true,
                              ),
                            _buildPriceRow('Taxes', taxAmount),
                            _buildPriceRow('Service Charge', serviceCharge),
                            const Divider(thickness: 2),
                            _buildPriceRow(
                              'Total',
                              (widget.room.price * numberOfNights) +
                                  taxAmount +
                                  serviceCharge -
                                  discountAmount,
                              isBold: true,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4E157),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isBold = false,
    bool isTotal = false,
    bool isNumber = false,
    bool isDiscount = false,
  }) {
    final textStyle = TextStyle(
      fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.normal,
      fontSize: isTotal ? 18 : 14,
      color: isDiscount ? Colors.green : null,
    );

    final formatter = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: textStyle),
          ),
          Text(
            isNumber ? amount.toInt().toString() : formatter.format(amount),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
