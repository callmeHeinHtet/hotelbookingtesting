import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';

/// Service for managing bookings in Firestore
class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

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
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('Error: User not authenticated');
        return null;
      }

      final booking = Booking(
        id: '', // Will be set by Firestore
        userId: userId,
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
        status: BookingStatus.upcoming,
        imagePath: imagePath,
        createdAt: DateTime.now(),
        transactionId: transactionId,
        paymentMethod: paymentMethod,
      );

      final docRef = await _bookingsCollection.add(booking.toFirestore());

      return booking.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error creating booking: $e');
      return null;
    }
  }

  /// Get all bookings for current user
  Future<List<Booking>> getBookings() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('Error: User not authenticated');
        return [];
      }

      final querySnapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      return [];
    }
  }

  /// Get bookings by status
  Future<List<Booking>> getBookingsByStatus(BookingStatus status) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('Error: User not authenticated');
        return [];
      }

      final querySnapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.displayName)
          .orderBy('checkInDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching bookings by status: $e');
      return [];
    }
  }

  /// Get upcoming bookings
  Future<List<Booking>> getUpcomingBookings() async {
    return getBookingsByStatus(BookingStatus.upcoming);
  }

  /// Get completed bookings
  Future<List<Booking>> getCompletedBookings() async {
    return getBookingsByStatus(BookingStatus.completed);
  }

  /// Get cancelled bookings
  Future<List<Booking>> getCancelledBookings() async {
    return getBookingsByStatus(BookingStatus.cancelled);
  }

  /// Get a single booking by ID
  Future<Booking?> getBooking(String bookingId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching booking: $e');
      return null;
    }
  }

  /// Update booking status
  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': status.displayName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      return false;
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    return updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  /// Check in to a booking
  Future<bool> checkIn(String bookingId) async {
    return updateBookingStatus(bookingId, BookingStatus.checkedIn);
  }

  /// Complete a booking
  Future<bool> completeBooking(String bookingId) async {
    return updateBookingStatus(bookingId, BookingStatus.completed);
  }

  /// Update booking details
  Future<bool> updateBooking(String bookingId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _bookingsCollection.doc(bookingId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating booking: $e');
      return false;
    }
  }

  /// Delete a booking
  Future<bool> deleteBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting booking: $e');
      return false;
    }
  }

  /// Stream of bookings for real-time updates
  Stream<List<Booking>> streamBookings() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  /// Get booking statistics for user
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      final bookings = await getBookings();

      int totalNights = 0;
      double totalSpent = 0;
      Map<String, int> roomTypeCounts = {};

      for (var booking in bookings) {
        if (booking.status == BookingStatus.completed) {
          totalNights += booking.numberOfNights;
          totalSpent += booking.totalAmount;

          roomTypeCounts[booking.roomTitle] =
              (roomTypeCounts[booking.roomTitle] ?? 0) + 1;
        }
      }

      // Find favorite room type
      String? favoriteRoom;
      int maxCount = 0;
      roomTypeCounts.forEach((room, count) {
        if (count > maxCount) {
          maxCount = count;
          favoriteRoom = room;
        }
      });

      return {
        'totalBookings': bookings.length,
        'completedBookings': bookings.where((b) => b.status == BookingStatus.completed).length,
        'upcomingBookings': bookings.where((b) => b.status == BookingStatus.upcoming).length,
        'cancelledBookings': bookings.where((b) => b.status == BookingStatus.cancelled).length,
        'totalNights': totalNights,
        'totalSpent': totalSpent,
        'favoriteRoom': favoriteRoom,
        'averageNightsPerStay': bookings.isEmpty ? 0 : totalNights / bookings.length,
      };
    } catch (e) {
      debugPrint('Error calculating statistics: $e');
      return {};
    }
  }

  /// Auto-update booking statuses based on dates
  Future<void> updateBookingStatusesAutomatically() async {
    try {
      final bookings = await getBookings();
      final now = DateTime.now();

      for (var booking in bookings) {
        if (booking.status == BookingStatus.upcoming) {
          // If check-in date has passed and check-out hasn't
          if (booking.checkInDate.isBefore(now) && booking.checkOutDate.isAfter(now)) {
            // Could be checked in - but don't auto-change, let user control this
          }
          // If check-out date has passed
          else if (booking.checkOutDate.isBefore(now)) {
            await completeBooking(booking.id);
          }
        } else if (booking.status == BookingStatus.checkedIn) {
          // If check-out date has passed
          if (booking.checkOutDate.isBefore(now)) {
            await completeBooking(booking.id);
          }
        }
      }
    } catch (e) {
      debugPrint('Error auto-updating booking statuses: $e');
    }
  }
}
