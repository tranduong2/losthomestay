import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/discount_model.dart';

class AppProvider extends ChangeNotifier {
  bool get isLive => false;
  bool loading = false;
  String? lastError;
  void clearError() {
    lastError = null;
    notifyListeners();
  }

  Future<void> sendContact(
      String name, String email, String phone, String message) async {
    throw StateError('Chức năng liên hệ cần kết nối Firebase.');
  }

  UserModel? currentUser;

  final List<RoomModel> rooms = List.from(MockData.rooms);
  final List<UserModel> users = List.from(MockData.users);
  final List<DiscountModel> discounts = List.from(MockData.discounts);
  final List<BookingModel> bookings = MockData.createBookings();

  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => currentUser?.role == UserRole.admin;

  // ----------------- AUTH -----------------
  FutureOr<String?> login(String email, String password) {
    final match = users.where(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase() &&
          u.password == password,
    );
    if (match.isEmpty) {
      return 'Email hoặc mật khẩu không đúng';
    }
    currentUser = match.first;
    notifyListeners();
    return null;
  }

  FutureOr<String?> register(
      String name, String email, String password, String phone) {
    final exists =
        users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return 'Email đã được sử dụng';
    final newUser = UserModel(
      id: 'U${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: UserRole.customer,
    );
    users.add(newUser);
    currentUser = null;
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  // ----------------- DISCOUNT -----------------
  FutureOr<DiscountModel?> validateDiscount(String code) {
    try {
      final d = discounts.firstWhere(
        (e) => e.code.toLowerCase() == code.trim().toLowerCase(),
      );
      return d.isValid ? d : null;
    } catch (_) {
      return null;
    }
  }

  // ----------------- BOOKING -----------------
  FutureOr<BookingModel> createBooking({
    required RoomModel room,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    DiscountModel? discount,
    required String paymentMethod,
    String? contactName,
    String? contactPhone,
  }) {
    final nights = checkOut.difference(checkIn).inDays.clamp(1, 999);
    final subtotal = room.pricePerNight * nights;
    final percent = discount?.percent ?? 0;
    final total = subtotal - (subtotal * percent / 100);

    final booking = BookingModel(
      id: 'BK${DateTime.now().millisecondsSinceEpoch}',
      roomId: room.id,
      roomName: room.name,
      userId: currentUser!.id,
      userName: contactName ?? currentUser!.name,
      contactPhone: contactPhone ?? currentUser!.phone,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      subtotal: subtotal,
      discountPercent: percent.toDouble(),
      total: total,
      createdAt: DateTime.now(),
      paymentMethod: paymentMethod,
      discountCode: discount?.code,
      status: BookingStatus.pending,
    );

    bookings.add(booking);
    room.status = RoomStatus.occupied;
    room.cleaningStatus = CleaningStatus.dirty;
    notifyListeners();
    return booking;
  }

  List<BookingModel> get myBookings => bookings
      .where((b) => b.userId == currentUser?.id)
      .toList()
      .reversed
      .toList();

  void cancelBooking(String bookingId) {
    final b = bookings.firstWhere((e) => e.id == bookingId);
    b.status = BookingStatus.cancelled;
    final room = rooms.firstWhere((e) => e.id == b.roomId);
    if (room.status != RoomStatus.maintenance)
      room.status = RoomStatus.available;
    notifyListeners();
  }

  // ----------------- ADMIN -----------------
  List<BookingModel> get allBookingsSorted =>
      List.from(bookings)..sort((a, b) => a.checkIn.compareTo(b.checkIn));

  void setRoomStatus(String roomId, RoomStatus status) {
    final r = rooms.firstWhere((e) => e.id == roomId);
    r.status = status;
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, BookingStatus status) {
    final booking = bookings.firstWhere((e) => e.id == bookingId);
    booking.status = status;
    final room = rooms.firstWhere((e) => e.id == booking.roomId);
    if (status == BookingStatus.confirmed) {
      room.status = RoomStatus.occupied;
    } else if (status == BookingStatus.cancelled &&
        room.status != RoomStatus.maintenance) {
      room.status = RoomStatus.available;
    } else if (status == BookingStatus.completed) {
      room.cleaningStatus = CleaningStatus.dirty;
    }
    notifyListeners();
  }

  void setCleaningStatus(String roomId, CleaningStatus status) {
    final r = rooms.firstWhere((e) => e.id == roomId);
    r.cleaningStatus = status;
    if (status == CleaningStatus.clean && r.status != RoomStatus.maintenance) {
      r.status = RoomStatus.available;
    }
    notifyListeners();
  }

  int get availableRoomCount =>
      rooms.where((r) => r.status == RoomStatus.available).length;

  List<BookingModel> bookingsOnDate(DateTime date) {
    return bookings.where((b) {
      final d = DateTime(date.year, date.month, date.day);
      final ci = DateTime(b.checkIn.year, b.checkIn.month, b.checkIn.day);
      final co = DateTime(b.checkOut.year, b.checkOut.month, b.checkOut.day);
      return b.status != BookingStatus.cancelled &&
          (d.isAtSameMomentAs(ci) ||
              d.isAtSameMomentAs(co) ||
              (d.isAfter(ci) && d.isBefore(co)));
    }).toList();
  }
}
