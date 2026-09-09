import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/app_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/app_theme.dart';

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
    final bookingsOnSelectedDay = provider.bookingsOnDate(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch đặt phòng')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) => provider.bookingsOnDate(day),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Đặt phòng ngày ${Formatters.date(_selectedDay)} (${bookingsOnSelectedDay.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: bookingsOnSelectedDay.isEmpty
                ? const Center(
                    child: Text('Không có đặt phòng vào ngày này',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookingsOnSelectedDay.length,
                    itemBuilder: (context, index) {
                      final b = bookingsOnSelectedDay[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading:
                              const Icon(Icons.event, color: AppTheme.primary),
                          title: Text(b.roomName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${b.userName}\n${Formatters.date(b.checkIn)} → ${Formatters.date(b.checkOut)}'),
                          isThreeLine: true,
                          trailing: Text(Formatters.currency(b.total),
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

