import 'package:flutter/material.dart';

class PaymentDetails {
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;
  final String zipCode;
  final DateTime paymentDate;
  final DateTime dueDate;
  final String transactionId;

  PaymentDetails({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    required this.zipCode,
    required this.paymentDate,
    required this.dueDate,
    required this.transactionId,
  });
}

class PaymentService {
  static const String bankName = "Cimso Bank";
  static const String accountName = "Cimso Hotel Co., Ltd";
  static const String accountNumber = "1234-5678-9012-3456";
  static const String swiftCode = "CIMTHBK";
  static const String bankBranch = "Bangkok Main Branch";

  // Validate card number using Luhn algorithm
  static bool validateCardNumber(String cardNumber) {
    if (cardNumber.isEmpty) return false;
    
    // Remove any spaces or dashes
    cardNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!RegExp(r'^[0-9]{16}$').hasMatch(cardNumber)) return false;

    int sum = 0;
    bool alternate = false;
    
    // Loop through values starting from the rightmost digit
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);
      
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    
    return (sum % 10 == 0);
  }

  // Validate expiry date
  static bool validateExpiryDate(String expiryDate) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;

    List<String> parts = expiryDate.split('/');
    int month = int.parse(parts[0]);
    int year = 2000 + int.parse(parts[1]);

    if (month < 1 || month > 12) return false;

    DateTime now = DateTime.now();
    DateTime cardExpiry = DateTime(year, month + 1, 0);

    return cardExpiry.isAfter(now);
  }

  // Validate CVV
  static bool validateCVV(String cvv) {
    return RegExp(r'^[0-9]{3,4}$').hasMatch(cvv);
  }

  // Validate ZIP code
  static bool validateZipCode(String zipCode) {
    return RegExp(r'^[0-9]{5}$').hasMatch(zipCode);
  }

  // Generate transaction ID
  static String generateTransactionId() {
    DateTime now = DateTime.now();
    String timestamp = now.millisecondsSinceEpoch.toString();
    return 'TXN${timestamp.substring(timestamp.length - 8)}';
  }

  // Process payment
  static Future<PaymentDetails?> processPayment({
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String cvv,
    required String zipCode,
  }) async {
    try {
      // Validate all fields
      if (!validateCardNumber(cardNumber)) throw 'Invalid card number';
      if (!validateExpiryDate(expiryDate)) throw 'Invalid expiry date';
      if (!validateCVV(cvv)) throw 'Invalid CVV';
      if (!validateZipCode(zipCode)) throw 'Invalid ZIP code';
      if (cardHolderName.isEmpty) throw 'Card holder name is required';

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate payment details
      DateTime paymentDate = DateTime.now();
      DateTime dueDate = paymentDate.add(const Duration(days: 7));
      String transactionId = generateTransactionId();

      return PaymentDetails(
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        cvv: cvv,
        zipCode: zipCode,
        paymentDate: paymentDate,
        dueDate: dueDate,
        transactionId: transactionId,
      );
    } catch (e) {
      debugPrint('Payment processing error: $e');
      return null;
    }
  }
} 