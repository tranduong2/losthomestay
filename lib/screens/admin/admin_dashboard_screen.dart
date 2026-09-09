import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import 'admin_ui.dart';

class AdminDashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  const AdminDashboardScreen({super.key, this.onNavigate});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final now = DateTime.now();
    final occupied =
        p.rooms.where((r) => r.status == RoomStatus.occupied).length;
    final pending =
        p.bookings.where((b) => b.status == BookingStatus.pending).length;
    final cleaning =
        p.rooms.where((r) => r.cleaningStatus != CleaningStatus.clean).length;
    final completed =
        p.bookings.where((b) => b.status == BookingStatus.completed);
    final revenue = completed.fold<double>(0, (sum, b) => sum + b.total);
    final recent = List<BookingModel>.from(p.bookings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final months =
        List.generate(6, (i) => DateTime(now.year, now.month - 5 + i));
    final values = months
        .map((m) => completed
            .where(
                (b) => b.checkOut.year == m.year && b.checkOut.month == m.month)
            .fold<double>(0, (sum, b) => sum + b.total))
        .toList();
    final maxValue = values.fold<double>(1, math.max);
    return AdminPage(
        title: 'Tổng quan vận hành',
        subtitle:
            '${Formatters.date(now)} · Mọi hoạt động của homestay trong một không gian.',
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 850;
          final availableWidth = constraints.maxWidth - 48;
          final statWidth =
              (availableWidth - (wide ? 48 : 16)) / (wide ? 4 : 2);
          final chart = AdminPanel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Doanh thu lưu trú',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                    '6 tháng gần nhất · Theo ngày trả phòng của đơn hoàn tất',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                const SizedBox(height: 28),
                SizedBox(
                    height: 180,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                            months.length,
                            (i) => Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              '${(values[i] / 1000000).toStringAsFixed(1)}tr',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.muted)),
                                          const SizedBox(height: 8),
                                          Tooltip(
                                              message: Formatters.currency(
                                                  values[i]),
                                              child: Container(
                                                  height: math.max(
                                                      4,
                                                      values[i] /
                                                          maxValue *
                                                          130),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      gradient: LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: i == 5
                                                              ? [
                                                                  adminBlue,
                                                                  const Color(
                                                                      0xFF2671D1)
                                                                ]
                                                              : [
                                                                  const Color(
                                                                      0xFF3D78BF),
                                                                  const Color(
                                                                      0xFF1C365D)
                                                                ])))),
                                          const SizedBox(height: 12),
                                          Text('T${months[i].month}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.muted)),
                                        ])))))),
              ]));
          final occupancy = AdminPanel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Tình trạng phòng',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                Center(
                    child: SizedBox(
                        width: 122,
                        height: 122,
                        child: Stack(alignment: Alignment.center, children: [
                          SizedBox.expand(
                              child: CircularProgressIndicator(
                                  value: p.rooms.isEmpty
                                      ? 0
                                      : occupied / p.rooms.length,
                                  strokeWidth: 11,
                                  backgroundColor: adminLine,
                                  color: adminBlue)),
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(
                                '${p.rooms.isEmpty ? 0 : (occupied / p.rooms.length * 100).round()}%',
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w800)),
                            const Text('đang có khách',
                                style: TextStyle(
                                    fontSize: 10, color: AppTheme.muted))
                          ]),
                        ]))),
                const SizedBox(height: 24),
                _legend('Phòng trống', p.availableRoomCount, adminBlue),
                _legend('Đang có khách', occupied, const Color(0xFF9AABFF)),
                _legend(
                    'Bảo trì',
                    p.rooms
                        .where((r) => r.status == RoomStatus.maintenance)
                        .length,
                    const Color(0xFFF3B86A)),
              ]));
          return ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
              children: [
                Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(colors: [
                          Color(0xFF183E72),
                          Color(0xFF142A52),
                          Color(0xFF18203E)
                        ]),
                        border: Border.all(color: const Color(0xFF305889))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CHÀO MỪNG TRỞ LẠI',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  color: adminBlue)),
                          const SizedBox(height: 10),
                          const Text('Sẵn sàng cho một ngày đón khách.',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.5)),
                          const SizedBox(height: 10),
                          Text(
                              '$pending đơn cần xác nhận · $cleaning phòng cần chăm sóc',
                              style: const TextStyle(color: AppTheme.muted)),
                          const SizedBox(height: 20),
                          Wrap(spacing: 12, runSpacing: 8, children: [
                            FilledButton.icon(
                                onPressed: onNavigate == null
                                    ? null
                                    : () => onNavigate!(2),
                                icon: const Icon(Icons.receipt_long_outlined,
                                    size: 18),
                                label: const Text('Xem đơn đặt phòng')),
                            OutlinedButton.icon(
                                onPressed: onNavigate == null
                                    ? null
                                    : () => onNavigate!(4),
                                icon: const Icon(Icons.calendar_month_outlined,
                                    size: 18),
                                label: const Text('Lịch lưu trú')),
                          ]),
                        ])),
                const SizedBox(height: 20),
                Wrap(spacing: 16, runSpacing: 16, children: [
                  _stat(
                      statWidth,
                      'Doanh thu hoàn tất',
                      Formatters.currency(revenue),
                      Icons.account_balance_wallet_outlined,
                      'Toàn bộ đơn đã trả phòng',
                      adminBlue),
                  _stat(
                      statWidth,
                      'Phòng sẵn có',
                      '${p.availableRoomCount} / ${p.rooms.length}',
                      Icons.bed_outlined,
                      'Theo trạng thái hiện tại',
                      const Color(0xFF83DFC8)),
                  _stat(
                      statWidth,
                      'Đơn chờ duyệt',
                      '$pending',
                      Icons.pending_actions_outlined,
                      'Cần xác nhận đặt phòng',
                      const Color(0xFFF3B86A)),
                  _stat(
                      statWidth,
                      'Cần dọn phòng',
                      '$cleaning',
                      Icons.cleaning_services_outlined,
                      'Chưa sẵn sàng đón khách',
                      const Color(0xFFA7B5FF)),
                ]),
                const SizedBox(height: 20),
                if (wide)
                  IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        Expanded(flex: 7, child: chart),
                        const SizedBox(width: 20),
                        Expanded(flex: 4, child: occupancy)
                      ]))
                else ...[chart, const SizedBox(height: 16), occupancy],
                const SizedBox(height: 20),
                AdminPanel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        const Expanded(
                            child: Text('Đơn đặt gần đây',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700))),
                        TextButton(
                            onPressed: onNavigate == null
                                ? null
                                : () => onNavigate!(2),
                            child: const Text('Xem tất cả'))
                      ]),
                      if (recent.isEmpty)
                        const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Chưa có đơn đặt phòng.')),
                      ...recent.take(5).map((b) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                    radius: 19,
                                    backgroundColor: Color(0xFF213954),
                                    child: Icon(Icons.person_outline,
                                        color: adminBlue, size: 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(b.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 5),
                                      Text(
                                          '${b.roomName} · ${Formatters.date(b.checkIn)}',
                                          style: const TextStyle(
                                              color: AppTheme.muted,
                                              fontSize: 12)),
                                      if (!wide)
                                        Text(Formatters.currency(b.total),
                                            style: const TextStyle(
                                                color: adminBlue,
                                                fontSize: 12)),
                                    ])),
                                if (wide)
                                  Text(Formatters.currency(b.total),
                                      style: const TextStyle(
                                          color: adminBlue,
                                          fontWeight: FontWeight.w600)),
                              ]))),
                    ])),
              ]);
        }));
  }

  Widget _stat(double width, String title, String value, IconData icon,
          String hint, Color color) =>
      SizedBox(
          width: width,
          child: AdminPanel(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, color: color, size: 21)),
                    const SizedBox(height: 16),
                    Text(title,
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 12)),
                    const SizedBox(height: 8),
                    SizedBox(
                        height: 30,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(value,
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)))),
                    const SizedBox(height: 8),
                    Text(hint,
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 10)),
                  ])));
  Widget _legend(String label, int value, Color color) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 9),
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: AppTheme.muted))),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w700))
      ]));
}
