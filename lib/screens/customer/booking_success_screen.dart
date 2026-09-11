import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../utils/formatters.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'main_navigation.dart';

class BookingSuccessScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: AppTheme.primary, size: 72),
              ),
              const SizedBox(height: 20),
              const Text('Đã gửi yêu cầu đặt phòng',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Đang chờ homestay xác nhận. Chưa thu tiền.',
                  textAlign: TextAlign.center),
              Text('Mã đặt phòng: ${booking.id}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row('Phòng', booking.roomName),
                      _row('Nhận phòng', Formatters.date(booking.checkIn)),
                      _row('Trả phòng', Formatters.date(booking.checkOut)),
                      _row('Số khách', '${booking.guests}'),
                      _row('Thanh toán', booking.paymentMethod),
                      const Divider(),
                      _row('Tổng tiền', Formatters.currency(booking.total),
                          bold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Về trang chủ',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigation()),
                  (r) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: bold ? AppTheme.primary : AppTheme.ink)),
        ],
      ),
    );
  }
}
