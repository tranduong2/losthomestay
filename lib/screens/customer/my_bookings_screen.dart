import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/formatters.dart';
import '../../utils/app_theme.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookings = provider.myBookings;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đặt phòng')),
      body: bookings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Bạn chưa có đặt phòng nào',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(b.roomName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            _statusChip(b.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                            '${Formatters.date(b.checkIn)} → ${Formatters.date(b.checkOut)} (${b.nights} đêm)'),
                        Text('${b.guests} khách • Mã: ${b.id}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(Formatters.currency(b.total),
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold)),
                            if (b.status == BookingStatus.confirmed)
                              TextButton(
                                onPressed: () => _confirmCancel(context, b.id),
                                child: const Text('Hủy đặt phòng',
                                    style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmCancel(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đặt phòng'),
        content: const Text('Bạn có chắc chắn muốn hủy đặt phòng này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Không')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().cancelBooking(bookingId);
              Navigator.pop(ctx);
            },
            child: const Text('Đồng ý', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BookingStatus status) {
    late Color color;
    late String label;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'Chờ xác nhận';
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        label = 'Đã xác nhận';
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        label = 'Hoàn thành';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Đã hủy';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

