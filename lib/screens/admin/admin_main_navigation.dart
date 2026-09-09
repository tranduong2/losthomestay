import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_rooms_screen.dart';
import 'admin_cleaning_screen.dart';
import 'admin_schedule_screen.dart';
import 'admin_bookings_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _index = 0;

  final _screens = const [
    AdminDashboardScreen(),
    AdminRoomsScreen(),
    AdminBookingsScreen(),
    AdminCleaningScreen(),
    AdminScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Tổng quan'),
          NavigationDestination(
              icon: Icon(Icons.meeting_room_outlined),
              selectedIcon: Icon(Icons.meeting_room),
              label: 'Phòng'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Đơn đặt'),
          NavigationDestination(
              icon: Icon(Icons.cleaning_services_outlined),
              selectedIcon: Icon(Icons.cleaning_services),
              label: 'Dọn phòng'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Lịch'),
        ],
      ),
    );
  }
}

