import 'package:cloud_firestore/cloud_firestore.dart';

/// Booking status enum for type-safe status handling
enum BookingStatus {
  upcoming,
  checkedIn,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return BookingStatus.upcoming;
      case 'checked in':
      case 'checkedin':
        return BookingStatus.checkedIn;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.upcoming;
    }
  }
}

/// Booking model with Firestore serialization
class Booking {
  final String id;
  final String userId;
  final String roomTitle;
  final String roomType;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final double roomPrice;
  final double subtotal;
  final double tax;
  final double serviceCharge;
  final double discountAmount;
  final double totalAmount;
  final String? appliedCouponCode;
  final double? couponDiscountPercentage;
  final BookingStatus status;
  final String imagePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? transactionId;
  final String? paymentMethod;

  Booking({
    required this.id,
    required this.userId,
    required this.roomTitle,
    this.roomType = '',
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.roomPrice,
    required this.subtotal,
    required this.tax,
    this.serviceCharge = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.appliedCouponCode,
    this.couponDiscountPercentage,
    required this.status,
    required this.imagePath,
    required this.createdAt,
    this.updatedAt,
    this.transactionId,
    this.paymentMethod,
  });

  /// Calculate number of nights
  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;

  /// Create Booking from Firestore document
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      roomTitle: data['roomTitle'] ?? '',
      roomType: data['roomType'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      guests: data['guests'] ?? 1,
      roomPrice: (data['roomPrice'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      serviceCharge: (data['serviceCharge'] ?? 0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      appliedCouponCode: data['appliedCouponCode'],
      couponDiscountPercentage: data['couponDiscountPercentage']?.toDouble(),
      status: BookingStatus.fromString(data['status'] ?? 'upcoming'),
      imagePath: data['imagePath'] ?? 'assets/images/default_room.jpg',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      transactionId: data['transactionId'],
      paymentMethod: data['paymentMethod'],
    );
  }

  /// Convert Booking to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'roomTitle': roomTitle,
      'roomType': roomType,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'guests': guests,
      'roomPrice': roomPrice,
      'subtotal': subtotal,
      'tax': tax,
      'serviceCharge': serviceCharge,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'appliedCouponCode': appliedCouponCode,
      'couponDiscountPercentage': couponDiscountPercentage,
      'status': status.displayName,
      'imagePath': imagePath,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    };
  }

  /// Create a copy with updated fields
  Booking copyWith({
    String? id,
    String? userId,
    String? roomTitle,
    String? roomType,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    double? roomPrice,
    double? subtotal,
    double? tax,
    double? serviceCharge,
    double? discountAmount,
    double? totalAmount,
    String? appliedCouponCode,
    double? couponDiscountPercentage,
    BookingStatus? status,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? transactionId,
    String? paymentMethod,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomTitle: roomTitle ?? this.roomTitle,
      roomType: roomType ?? this.roomType,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      roomPrice: roomPrice ?? this.roomPrice,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      couponDiscountPercentage: couponDiscountPercentage ?? this.couponDiscountPercentage,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  /// Convert to Map for legacy compatibility
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'roomTitle': roomTitle,
      'roomType': roomType,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'guests': guests,
      'roomPrice': roomPrice,
      'subtotal': subtotal,
      'tax': tax,
      'serviceCharge': serviceCharge,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'appliedCouponCode': appliedCouponCode,
      'couponDiscountPercentage': couponDiscountPercentage,
      'status': status.displayName,
      'imagePath': imagePath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    };
  }

  /// Create from legacy Map format
  factory Booking.fromMap(Map<String, dynamic> map, {String? id}) {
    return Booking(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      roomTitle: map['roomTitle'] ?? '',
      roomType: map['roomType'] ?? '',
      checkInDate: map['checkInDate'] is DateTime
          ? map['checkInDate']
          : DateTime.parse(map['checkInDate']),
      checkOutDate: map['checkOutDate'] is DateTime
          ? map['checkOutDate']
          : DateTime.parse(map['checkOutDate']),
      guests: map['guests'] ?? 1,
      roomPrice: (map['roomPrice'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? map['totalAmount'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      serviceCharge: (map['serviceCharge'] ?? 0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      appliedCouponCode: map['appliedCouponCode'],
      couponDiscountPercentage: map['couponDiscountPercentage']?.toDouble(),
      status: BookingStatus.fromString(map['status'] ?? 'upcoming'),
      imagePath: map['imagePath'] ?? map['image'] ?? 'assets/images/default_room.jpg',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime ? map['updatedAt'] : null,
      transactionId: map['transactionId'],
      paymentMethod: map['paymentMethod'],
    );
  }
}
