import 'package:flutter_test/flutter_test.dart';
import 'package:homestay_app/data/mock_data.dart';
import 'package:homestay_app/models/booking_model.dart';
import 'package:homestay_app/models/room_model.dart';

void main() {
  test('demo bookings have valid references, totals and calendar dates', () {
    final rooms = MockData.rooms;
    final users = MockData.users;
    final now = DateTime(2026, 12, 31);
    final bookings = MockData.createBookings(now: now);
    expect(rooms.length, 12);
    expect(bookings.length, 30);
    expect(bookings.map((b) => b.id).toSet().length, bookings.length);
    expect(bookings.map((b) => b.status).toSet(), BookingStatus.values.toSet());
    for (final b in bookings) {
      final room = rooms.singleWhere((r) => r.id == b.roomId);
      expect(users.any((u) => u.id == b.userId), isTrue);
      expect(b.nights, greaterThan(0));
      expect(b.guests, lessThanOrEqualTo(room.maxGuests));
      expect(b.subtotal, room.pricePerNight * b.nights);
      expect(b.total, b.subtotal * (100 - b.discountPercent) / 100);
      expect(b.createdAt.isBefore(now), isTrue);
    }
    expect(bookings.any((b) => b.checkIn.isAfter(now)), isTrue);
    final first = MockData.rooms;
    first.first.status = RoomStatus.maintenance;
    expect(MockData.rooms.first.status, RoomStatus.available);
  });
}
