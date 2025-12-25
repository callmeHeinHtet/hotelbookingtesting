import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

/// Provider for managing booking state
class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _completedBookings = [];
  List<Booking> _cancelledBookings = [];
  Map<String, dynamic> _statistics = {};

  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Booking>>? _bookingsSubscription;

  // Getters
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Booking> get upcomingBookings => List.unmodifiable(_upcomingBookings);
  List<Booking> get completedBookings => List.unmodifiable(_completedBookings);
  List<Booking> get cancelledBookings => List.unmodifiable(_cancelledBookings);
  Map<String, dynamic> get statistics => Map.unmodifiable(_statistics);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics getters
  int get totalBookings => _statistics['totalBookings'] ?? 0;
  int get totalNights => _statistics['totalNights'] ?? 0;
  double get totalSpent => (_statistics['totalSpent'] ?? 0).toDouble();
  String? get favoriteRoom => _statistics['favoriteRoom'];

  /// Initialize provider and start listening to bookings
  Future<void> initialize() async {
    await loadBookings();
    _startListeningToBookings();
  }

  /// Start listening to real-time booking updates
  void _startListeningToBookings() {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _bookingService.streamBookings().listen(
      (bookings) {
        _bookings = bookings;
        _categorizeBookings();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error in bookings stream: $e');
        _error = 'Failed to sync bookings';
        notifyListeners();
      },
    );
  }

  /// Load all bookings
  Future<void> loadBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _bookingService.getBookings();
      _categorizeBookings();
      await _loadStatistics();

      // Auto-update statuses based on dates
      await _bookingService.updateBookingStatusesAutomatically();
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      _error = 'Failed to load bookings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Categorize bookings by status
  void _categorizeBookings() {
    _upcomingBookings = _bookings
        .where((b) => b.status == BookingStatus.upcoming)
        .toList();
    _completedBookings = _bookings
        .where((b) => b.status == BookingStatus.completed)
        .toList();
    _cancelledBookings = _bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList();
  }

  /// Load booking statistics
  Future<void> _loadStatistics() async {
    _statistics = await _bookingService.getBookingStatistics();
  }

  /// Create a new booking
  Future<Booking?> createBooking({
    required String roomTitle,
    required String roomType,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guests,
    required double roomPrice,
    required double subtotal,
    required double tax,
    double serviceCharge = 0,
    double discountAmount = 0,
    required double totalAmount,
    String? appliedCouponCode,
    double? couponDiscountPercentage,
    required String imagePath,
    String? transactionId,
    String? paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = await _bookingService.createBooking(
        roomTitle: roomTitle,
        roomType: roomType,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guests: guests,
        roomPrice: roomPrice,
        subtotal: subtotal,
        tax: tax,
        serviceCharge: serviceCharge,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        appliedCouponCode: appliedCouponCode,
        couponDiscountPercentage: couponDiscountPercentage,
        imagePath: imagePath,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
      );

      if (booking != null) {
        _bookings.insert(0, booking);
        _categorizeBookings();
        await _loadStatistics();
      } else {
        _error = 'Failed to create booking';
      }

      return booking;
    } catch (e) {
      debugPrint('Error creating booking: $e');
      _error = 'Failed to create booking';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _bookingService.cancelBooking(bookingId);

      if (success) {
        // Update local state
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = _bookings[index].copyWith(
            status: BookingStatus.cancelled,
            updatedAt: DateTime.now(),
          );
          _categorizeBookings();
        }
      } else {
        _error = 'Failed to cancel booking';
      }

      return success;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      _error = 'Failed to cancel booking';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check in to a booking
  Future<bool> checkIn(String bookingId) async {
    try {
      final success = await _bookingService.checkIn(bookingId);

      if (success) {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = _bookings[index].copyWith(
            status: BookingStatus.checkedIn,
            updatedAt: DateTime.now(),
          );
          _categorizeBookings();
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      debugPrint('Error checking in: $e');
      return false;
    }
  }

  /// Complete a booking
  Future<bool> completeBooking(String bookingId) async {
    try {
      final success = await _bookingService.completeBooking(bookingId);

      if (success) {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = _bookings[index].copyWith(
            status: BookingStatus.completed,
            updatedAt: DateTime.now(),
          );
          _categorizeBookings();
          await _loadStatistics();
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      debugPrint('Error completing booking: $e');
      return false;
    }
  }

  /// Get a booking by ID
  Booking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh bookings
  Future<void> refresh() async {
    await loadBookings();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
