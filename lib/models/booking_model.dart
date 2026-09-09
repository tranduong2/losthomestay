enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingModel {
  final String id;
  final String roomId;
  final String roomName;
  final String userId;
  final String userName;
  final String? contactPhone;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double subtotal;
  final double discountPercent;
  final double total;
  final String? discountCode;
  final DateTime createdAt;
  BookingStatus status;
  final String paymentMethod;

  BookingModel({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.userId,
    required this.userName,
    this.contactPhone,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.subtotal,
    required this.discountPercent,
    required this.total,
    required this.createdAt,
    required this.paymentMethod,
    this.discountCode,
    this.status = BookingStatus.confirmed,
  });

  int get nights => checkOut.difference(checkIn).inDays;
}

