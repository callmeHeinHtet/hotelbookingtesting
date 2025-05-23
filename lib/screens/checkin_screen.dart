import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_details_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../constants/app_constants.dart';
import '../utils/types.dart';

/// A screen that handles hotel room check-in process.
/// 
/// Allows users to:
/// - Select check-in and check-out dates
/// - Choose number of guests
/// - View pricing breakdown including taxes
/// - Proceed to payment
class CheckInScreen extends StatefulWidget {
  final String roomTitle;
  final double roomPrice;
  final String imagePath;

  const CheckInScreen({
    Key? key,
    required this.roomTitle,
    required this.roomPrice,
    required this.imagePath,
  }) : super(key: key);

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = AppConstants.minGuests;
  bool _isLoading = false;
  late final ValueNotifier<_BookingCalculation> _calculation;

  @override
  void initState() {
    super.initState();
    _calculation = ValueNotifier<_BookingCalculation>(_BookingCalculation.empty());
  }

  @override
  void dispose() {
    _calculation.dispose();
    super.dispose();
  }

  /// Shows a date picker and handles the selection for check-in/check-out dates
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    try {
      setState(() => _isLoading = true);
      
      final DateTime initialDate = isCheckIn 
          ? DateTime.now() 
          : (_checkInDate ?? DateTime.now()).add(const Duration(days: 1));
          
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );

      if (picked != null) {
        setState(() {
          if (isCheckIn) {
            _checkInDate = picked;
            _checkOutDate = null;
          } else {
            _checkOutDate = picked;
          }
          _updateCalculation();
        });
      }
    } catch (e) {
      debugPrint('Error selecting date: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error selecting date. Please try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Updates the booking calculation based on selected dates
  void _updateCalculation() {
    try {
      if (_checkInDate != null && _checkOutDate != null) {
        final nights = _checkOutDate!.difference(_checkInDate!).inDays;
        if (nights > 0) {
          _calculation.value = _BookingCalculation(
            nights: nights,
            baseAmount: widget.roomPrice * nights,
            taxRate: AppConstants.taxRate,
          );
          debugPrint('Booking calculation updated: nights=$nights, total=${_calculation.value.totalAmount}');
        }
      } else {
        _calculation.value = _BookingCalculation.empty();
      }
    } catch (e) {
      debugPrint('Error updating booking calculation: $e');
      _calculation.value = _BookingCalculation.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      appBar: AppBar(
        backgroundColor: AppConstants.blackColor,
        elevation: 0,
        title: Text(AppStrings.checkIn, style: TextStyle(color: AppConstants.whiteColor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConstants.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.defaultPadding),

                _RoomHeader(
                  key: const Key('room_header'),
                  imagePath: widget.imagePath,
                  title: widget.roomTitle,
                  price: widget.roomPrice,
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                Text(
                  AppStrings.selectStayDuration,
                  style: AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _DateSelectionRow(
                  key: const Key('date_selection'),
                  checkInDate: _checkInDate,
                  checkOutDate: _checkOutDate,
                  onCheckInSelect: () => _selectDate(context, true),
                  onCheckOutSelect: () => _selectDate(context, false),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                _GuestCounter(
                  key: const Key('guest_counter'),
                  guests: _guests,
                  onDecrement: () {
                    if (_guests > AppConstants.minGuests) {
                      setState(() => _guests--);
                    }
                  },
                  onIncrement: () {
                    if (_guests < AppConstants.maxGuests) {
                      setState(() => _guests++);
                    }
                  },
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                ValueListenableBuilder<_BookingCalculation>(
                  valueListenable: _calculation,
                  builder: (context, calculation, _) {
                    if (calculation.nights == 0) return const SizedBox.shrink();
                    return _BookingSummary(
                      key: const Key('booking_summary'),
                      calculation: calculation,
                    );
                  },
                ),

                const SizedBox(height: 30),

                Center(
                  child: _ContinueButton(
                    key: const Key('continue_button'),
                    enabled: _checkInDate != null && _checkOutDate != null,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            roomTitle: widget.roomTitle,
                            checkInDate: _checkInDate!,
                            checkOutDate: _checkOutDate!,
                            guests: _guests,
                            totalAmount: _calculation.value.totalAmount,
                            nights: _calculation.value.nights,
                            unitPrice: widget.roomPrice,
                            imagePath: widget.imagePath,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
    );
  }
}

/// Represents a booking calculation with tax
class _BookingCalculation {
  final int nights;
  final double baseAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;

  _BookingCalculation({
    required this.nights,
    required this.baseAmount,
    required this.taxRate,
  }) : taxAmount = baseAmount * taxRate,
       totalAmount = baseAmount + (baseAmount * taxRate);

  factory _BookingCalculation.empty() => _BookingCalculation(
    nights: 0,
    baseAmount: 0,
    taxRate: AppConstants.taxRate,
  );
}

/// Displays the room header with image and basic information
class _RoomHeader extends StatelessWidget {
  final String imagePath;
  final String title;
  final double price;

  const _RoomHeader({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: AppConstants.roomImageHeight,
              fit: BoxFit.cover,
              cacheWidth: 720, // 2x for high DPI displays
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return Container(
                  width: double.infinity,
                  height: AppConstants.roomImageHeight,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error_outline, size: 50),
                );
              },
            ),
          ),
        ),
        Text(title, style: AppStyles.headerStyle),
        Text(
          '${AppStrings.currencySymbol} ${price.toStringAsFixed(2)} ${AppStrings.perNight}',
          style: AppStyles.subheaderStyle,
        ),
      ],
    );
  }
}

/// Displays a row of date selection buttons
class _DateSelectionRow extends StatelessWidget {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final VoidCallback onCheckInSelect;
  final VoidCallback onCheckOutSelect;

  const _DateSelectionRow({
    Key? key,
    required this.checkInDate,
    required this.checkOutDate,
    required this.onCheckInSelect,
    required this.onCheckOutSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _DateSelector(
          key: const Key('check_in_selector'),
          label: AppStrings.checkInDate,
          date: checkInDate,
          onTap: onCheckInSelect,
          enabled: true,
        ),
        _DateSelector(
          key: const Key('check_out_selector'),
          label: AppStrings.checkOutDate,
          date: checkOutDate,
          onTap: onCheckOutSelect,
          enabled: checkInDate != null,
        ),
      ],
    );
  }
}

/// A single date selector button
class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool enabled;

  const _DateSelector({
    Key? key,
    required this.label,
    required this.date,
    required this.onTap,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Select $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppConstants.minTouchTargetSize,
              minWidth: AppConstants.minTouchTargetSize,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: enabled ? AppConstants.blackColor : AppConstants.greyColor,
              ),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
            child: Text(
              date == null ? label : DateFormat('dd MMM yyyy').format(date!),
              style: AppStyles.bodyStyle.copyWith(
                color: enabled ? AppConstants.blackColor : AppConstants.greyColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Counter widget for selecting number of guests
class _GuestCounter extends StatelessWidget {
  final int guests;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _GuestCounter({
    Key? key,
    required this.guests,
    required this.onDecrement,
    required this.onIncrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppStrings.guests, style: AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Semantics(
              button: true,
              enabled: guests > AppConstants.minGuests,
              label: 'Decrease number of guests',
              child: IconButton(
                onPressed: guests > AppConstants.minGuests ? onDecrement : null,
                icon: const Icon(Icons.remove_circle_outline),
                constraints: const BoxConstraints(
                  minHeight: AppConstants.minTouchTargetSize,
                  minWidth: AppConstants.minTouchTargetSize,
                ),
              ),
            ),
            Semantics(
              label: 'Number of guests',
              value: guests.toString(),
              child: Text(
                guests.toString(),
                style: AppStyles.subheaderStyle,
              ),
            ),
            Semantics(
              button: true,
              enabled: guests < AppConstants.maxGuests,
              label: 'Increase number of guests',
              child: IconButton(
                onPressed: guests < AppConstants.maxGuests ? onIncrement : null,
                icon: const Icon(Icons.add_circle_outline),
                constraints: const BoxConstraints(
                  minHeight: AppConstants.minTouchTargetSize,
                  minWidth: AppConstants.minTouchTargetSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Displays the booking summary with cost breakdown
class _BookingSummary extends StatelessWidget {
  final _BookingCalculation calculation;

  const _BookingSummary({
    Key? key,
    required this.calculation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.nights} ${calculation.nights}',
          style: AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          '${AppStrings.subtotal} ${AppStrings.currencySymbol} ${calculation.baseAmount.toStringAsFixed(2)}',
          style: AppStyles.bodyStyle,
        ),
        const SizedBox(height: 5),
        Text(
          '${AppStrings.tax} ${AppStrings.currencySymbol} ${calculation.taxAmount.toStringAsFixed(2)}',
          style: AppStyles.bodyStyle.copyWith(color: AppConstants.redAccentColor),
        ),
        const SizedBox(height: 5),
        Text(
          '${AppStrings.total} ${AppStrings.currencySymbol} ${calculation.totalAmount.toStringAsFixed(2)}',
          style: AppStyles.priceStyle,
        ),
      ],
    );
  }
}

/// Continue button for proceeding to payment
class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _ContinueButton({
    Key? key,
    required this.enabled,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Continue to payment',
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          minimumSize: const Size(
            AppConstants.minTouchTargetSize * 3,
            AppConstants.minTouchTargetSize,
          ),
        ),
        child: Text(
          AppStrings.continue_,
          style: AppStyles.subheaderStyle.copyWith(color: AppConstants.blackColor),
        ),
      ),
    );
  }
}
