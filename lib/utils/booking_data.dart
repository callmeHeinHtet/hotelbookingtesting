// booking_data.dart

// Global list to store booking history
List<Map<String, dynamic>> bookingHistory = [];

// Function to add a new booking to the history
void addBooking({
  required String roomTitle,
  required DateTime checkInDate,
  required DateTime checkOutDate,
  required int guests,
  required double totalAmount,
  required String status,
  String? imagePath, // Optional image path
}) {
  bookingHistory.add({
    "roomTitle": roomTitle,
    "checkInDate": checkInDate,
    "checkOutDate": checkOutDate,
    "guests": guests,
    "totalAmount": totalAmount,
    "status": status,
    "image": imagePath, // Add image path if provided
  });
}

// Function to update booking status (e.g., from "Upcoming" to "Cancelled")
void updateBookingStatus(int index, String newStatus) {
  if (index >= 0 && index < bookingHistory.length) {
    bookingHistory[index]["status"] = newStatus;
  }
}

// Function to get all bookings
List<Map<String, dynamic>> getAllBookings() {
  return bookingHistory;
}

// Function to get bookings by status (e.g., "Upcoming", "Completed", "Cancelled")
List<Map<String, dynamic>> getBookingsByStatus(String status) {
  return bookingHistory.where((booking) => booking["status"] == status).toList();
}

// ✅ Dummy Data (Add Sample Bookings)
void initializeDummyBookings() {
  addBooking(
    roomTitle: "Deluxe Room",
    checkInDate: DateTime(2025, 2, 10),
    checkOutDate: DateTime(2025, 2, 12),
    guests: 2,
    totalAmount: 5000,
    status: "Completed",
    imagePath: "assets/images/deluxe_room.jpg",
  );

  addBooking(
    roomTitle: "Superior Suite",
    checkInDate: DateTime(2025, 1, 15),
    checkOutDate: DateTime(2025, 1, 20),
    guests: 3,
    totalAmount: 7000,
    status: "Completed",
    imagePath: "assets/images/superior_room.jpg",
  );

  // ✅ Add an Upcoming Booking for Testing

}
