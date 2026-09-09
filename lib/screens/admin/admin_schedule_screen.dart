import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/app_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/app_theme.dart';
import 'admin_ui.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});
  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookings = provider.bookingsOnDate(_selectedDay);
    final calendar = AdminPanel(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selected, focused) => setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          }),
          onPageChanged: (focused) => _focusedDay = focused,
          calendarFormat: CalendarFormat.month,
          eventLoader: provider.bookingsOnDate,
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: AppTheme.ink),
            weekendTextStyle: const TextStyle(color: adminBlue),
            selectedTextStyle:
                const TextStyle(color: adminBg, fontWeight: FontWeight.bold),
            todayDecoration: BoxDecoration(
                color: adminBlue.withValues(alpha: .18),
                shape: BoxShape.circle),
            selectedDecoration:
                const BoxDecoration(color: adminBlue, shape: BoxShape.circle),
            markerDecoration:
                const BoxDecoration(color: adminBlue, shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
        ));
    final agenda = AdminPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Lịch trong ngày',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('${Formatters.date(_selectedDay)} · ${bookings.length} lượt lưu trú',
          style: const TextStyle(color: adminBlue, fontSize: 13)),
      const SizedBox(height: 24),
      if (bookings.isEmpty)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Column(children: [
              Icon(Icons.event_available_outlined,
                  color: AppTheme.muted, size: 40),
              SizedBox(height: 16),
              Text('Không có đặt phòng vào ngày này',
                  style: TextStyle(color: AppTheme.muted))
            ])),
      ...bookings.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Container(
              padding: const EdgeInsets.only(left: 14),
              decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: adminBlue, width: 3))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.roomName,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('${b.userName} · ${b.guests} khách',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.muted)),
                    const SizedBox(height: 6),
                    Text(
                        '${Formatters.date(b.checkIn)} → ${Formatters.date(b.checkOut)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.muted)),
                    const SizedBox(height: 8),
                    Text(Formatters.currency(b.total),
                        style: const TextStyle(color: adminBlue)),
                  ])))),
    ]));
    return AdminPage(
        title: 'Lịch lưu trú',
        subtitle: 'Chọn một ngày để xem khách lưu trú và chuẩn bị đón tiếp.',
        child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: c.maxWidth >= 850
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Expanded(flex: 6, child: calendar),
                              const SizedBox(width: 20),
                              Expanded(flex: 4, child: agenda)
                            ])
                      : Column(children: [
                          calendar,
                          const SizedBox(height: 20),
                          agenda
                        ]),
                )));
  }
}
