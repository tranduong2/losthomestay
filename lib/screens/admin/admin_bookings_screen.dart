import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});
  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  BookingStatus? _filter;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookings = provider.allBookingsSorted
        .where((b) => _filter == null || b.status == _filter)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đặt phòng')),
      body: Column(children: [
        SizedBox(
            height: 52,
            child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                children: [
                  _chip('Tất cả', null),
                  _chip('Chờ duyệt', BookingStatus.pending),
                  _chip('Đã xác nhận', BookingStatus.confirmed),
                  _chip('Hoàn tất', BookingStatus.completed),
                ])),
        Expanded(
            child: bookings.isEmpty
                ? const Center(
                    child: Text('Chưa có đơn đặt phòng phù hợp',
                        style: TextStyle(color: AppTheme.muted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final b = bookings[index];
                      return Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                          child: Text(b.roomName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16))),
                                      _badge(b.status)
                                    ]),
                                    const SizedBox(height: 8),
                                    Text('${b.userName}  •  ${b.guests} khách',
                                        style: const TextStyle(
                                            color: AppTheme.muted)),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${Formatters.date(b.checkIn)}  →  ${Formatters.date(b.checkOut)} · ${b.nights} đêm',
                                        style: const TextStyle(
                                            color: AppTheme.muted,
                                            fontSize: 13)),
                                    const Divider(height: 22),
                                    Row(children: [
                                      Expanded(
                                          child: Text(
                                              Formatters.currency(b.total),
                                              style: const TextStyle(
                                                  color: AppTheme.primary,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      if (b.status ==
                                          BookingStatus.pending) ...[
                                        TextButton(
                                            onPressed: () =>
                                                provider.updateBookingStatus(
                                                    b.id,
                                                    BookingStatus.cancelled),
                                            child: const Text('Từ chối',
                                                style: TextStyle(
                                                    color: Colors.red))),
                                        const SizedBox(width: 6),
                                        FilledButton(
                                            onPressed: () =>
                                                provider.updateBookingStatus(
                                                    b.id,
                                                    BookingStatus.confirmed),
                                            child: const Text('Xác nhận')),
                                      ] else if (b.status ==
                                          BookingStatus.confirmed)
                                        FilledButton.tonal(
                                            onPressed: () =>
                                                provider.updateBookingStatus(
                                                    b.id,
                                                    BookingStatus.completed),
                                            child: const Text('Trả phòng'))
                                    ])
                                  ])));
                    },
                  )),
      ]),
    );
  }

  Widget _chip(String label, BookingStatus? status) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
          label: Text(label),
          selected: _filter == status,
          onSelected: (_) => setState(() => _filter = status)));
  Widget _badge(BookingStatus status) {
    final data = switch (status) {
      BookingStatus.pending => ('Chờ duyệt', Colors.orange),
      BookingStatus.confirmed => ('Đã xác nhận', AppTheme.primary),
      BookingStatus.completed => ('Hoàn tất', Colors.blue),
      BookingStatus.cancelled => ('Đã hủy', Colors.red)
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: data.$2.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(20)),
        child: Text(data.$1,
            style: TextStyle(
                color: data.$2, fontWeight: FontWeight.w700, fontSize: 11)));
  }
}

