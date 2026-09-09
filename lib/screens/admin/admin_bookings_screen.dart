import 'admin_ui.dart';
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
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookings = provider.allBookingsSorted
        .where((b) =>
            (_filter == null || b.status == _filter) &&
            ('${b.id} ${b.userName} ${b.roomName}')
                .toLowerCase()
                .contains(_query))
        .toList();
    return AdminPage(
      title: 'Đơn đặt phòng',
      subtitle: 'Kiểm tra thông tin khách, xác nhận đơn và quản lý trả phòng.',
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm mã đơn, tên khách hoặc phòng'),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            )),
        const SizedBox(height: 8),
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
                  _chip('Đã hủy', BookingStatus.cancelled),
                ])),
        Expanded(
            child: bookings.isEmpty
                ? const Center(
                    child: Text('Chưa có đơn đặt phòng phù hợp',
                        style: TextStyle(color: AppTheme.muted)))
                : MediaQuery.sizeOf(context).width >= 1100
                    ? _table(bookings, provider)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                              child: Text(b.roomName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16))),
                                          _badge(b.status)
                                        ]),
                                        const SizedBox(height: 8),
                                        Text(
                                            '${b.userName}  •  ${b.guests} khách',
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
                                                onPressed: () => provider
                                                    .updateBookingStatus(
                                                        b.id,
                                                        BookingStatus
                                                            .cancelled),
                                                child: const Text('Từ chối',
                                                    style: TextStyle(
                                                        color: Colors.red))),
                                            const SizedBox(width: 6),
                                            FilledButton(
                                                onPressed: () => provider
                                                    .updateBookingStatus(
                                                        b.id,
                                                        BookingStatus
                                                            .confirmed),
                                                child: const Text('Xác nhận')),
                                          ] else if (b.status ==
                                              BookingStatus.confirmed)
                                            FilledButton.tonal(
                                                onPressed: () => provider
                                                    .updateBookingStatus(
                                                        b.id,
                                                        BookingStatus
                                                            .completed),
                                                child: const Text('Trả phòng'))
                                        ])
                                      ])));
                        },
                      )),
      ]),
    );
  }

  Widget _table(List<BookingModel> bookings, AppProvider provider) =>
      SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AdminPanel(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 52,
                    dataRowMinHeight: 76,
                    dataRowMaxHeight: 88,
                    columnSpacing: 24,
                    headingRowColor:
                        const WidgetStatePropertyAll(Color(0xFF172944)),
                    columns: const [
                      DataColumn(label: Text('Khách hàng / Mã đơn')),
                      DataColumn(label: Text('Phòng & lưu trú')),
                      DataColumn(label: Text('Tổng tiền')),
                      DataColumn(label: Text('Trạng thái')),
                      DataColumn(label: Text('Thao tác'))
                    ],
                    rows: bookings
                        .map((b) => DataRow(cells: [
                              DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    Text(b.id,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.muted))
                                  ])),
                              DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.roomName),
                                    const SizedBox(height: 6),
                                    Text(
                                        '${Formatters.date(b.checkIn)} → ${Formatters.date(b.checkOut)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.muted))
                                  ])),
                              DataCell(Text(Formatters.currency(b.total),
                                  style: const TextStyle(color: adminBlue))),
                              DataCell(_badge(b.status)),
                              DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (b.status == BookingStatus.pending) ...[
                                      IconButton(
                                          tooltip: 'Từ chối đơn',
                                          icon: const Icon(Icons.close,
                                              color: Colors.redAccent,
                                              size: 18),
                                          onPressed: () =>
                                              provider.updateBookingStatus(b.id,
                                                  BookingStatus.cancelled)),
                                      FilledButton.tonal(
                                          onPressed: () =>
                                              provider.updateBookingStatus(b.id,
                                                  BookingStatus.confirmed),
                                          child: const Text('Xác nhận')),
                                    ] else if (b.status ==
                                        BookingStatus.confirmed)
                                      FilledButton.tonal(
                                          onPressed: () =>
                                              provider.updateBookingStatus(b.id,
                                                  BookingStatus.completed),
                                          child: const Text('Trả phòng'))
                                    else
                                      const Text('—',
                                          style:
                                              TextStyle(color: AppTheme.muted)),
                                  ])),
                            ]))
                        .toList(),
                  ))));

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
