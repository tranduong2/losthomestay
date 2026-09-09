import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../models/discount_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';
import 'booking_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final RoomModel room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final DiscountModel? discount;
  final double subtotal;
  final double total;
  final String? contactName;
  final String? contactPhone;

  const PaymentScreen({
    super.key,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.discount,
    required this.subtotal,
    required this.total,
    this.contactName,
    this.contactPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'Thẻ tín dụng/ghi nợ';
  bool _processing = false;

  final _methods = const [
    {'name': 'Thẻ tín dụng/ghi nợ', 'icon': Icons.credit_card},
    {'name': 'Ví MoMo', 'icon': Icons.account_balance_wallet_outlined},
    {'name': 'Chuyển khoản ngân hàng', 'icon': Icons.account_balance_outlined},
    {'name': 'Thanh toán tại homestay', 'icon': Icons.home_outlined},
  ];

  void _pay() async {
    final provider = context.read<AppProvider>();
    if (!provider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng đăng nhập trước khi đặt phòng.')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final booking = provider.createBooking(
      room: widget.room,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      guests: widget.guests,
      discount: widget.discount,
      paymentMethod: _method,
      contactName: widget.contactName,
      contactPhone: widget.contactPhone,
    );
    setState(() => _processing = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => BookingSuccessScreen(booking: booking)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nights = widget.checkOut.difference(widget.checkIn).inDays;
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.room.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        '${Formatters.date(widget.checkIn)} → ${Formatters.date(widget.checkOut)} ($nights đêm)'),
                    Text('${widget.guests} khách'),
                    if (widget.discount != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                            'Mã: ${widget.discount!.code} (-${widget.discount!.percent.toStringAsFixed(0)}%)',
                            style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Chọn phương thức thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            RadioGroup<String>(
              groupValue: _method,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _method = value);
                }
              },
              child: Column(
                children: _methods.map((m) {
                  final selected = _method == m['name'];
                  return Card(
                    color: selected
                        ? AppTheme.primary.withValues(alpha: 0.08)
                        : AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            selected ? AppTheme.primary : Colors.grey.shade200,
                      ),
                    ),
                    child: RadioListTile<String>(
                      value: m['name'] as String,
                      activeColor: AppTheme.primary,
                      secondary:
                          Icon(m['icon'] as IconData, color: AppTheme.primary),
                      title: Text(m['name'] as String),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 20,
              runSpacing: 8,
              children: [
                const Text('Tổng thanh toán',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(Formatters.currency(widget.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Xác nhận thanh toán',
              onPressed: _pay,
              loading: _processing,
              icon: Icons.lock_outline,
            ),
          ],
        ),
      ),
    );
  }
}


