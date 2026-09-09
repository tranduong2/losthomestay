import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final rooms = provider.rooms;
    final totalRooms = rooms.length;
    final available =
        rooms.where((r) => r.status == RoomStatus.available).length;
    final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
    final maintenance =
        rooms.where((r) => r.status == RoomStatus.maintenance).length;
    final needCleaning =
        rooms.where((r) => r.cleaningStatus != CleaningStatus.clean).length;
    final todayBookings = provider.bookingsOnDate(DateTime.now());
    final revenue = provider.bookings
        .where((b) => b.status != BookingStatus.cancelled)
        .fold<double>(0, (sum, b) => sum + b.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              provider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Xin chào, ${provider.currentUser?.name}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _statCard('Tổng số phòng', '$totalRooms', Icons.meeting_room,
                  AppTheme.primary),
              _statCard('Phòng trống', '$available', Icons.check_circle_outline,
                  Colors.green),
              _statCard(
                  'Đang có khách', '$occupied', Icons.person, Colors.orange),
              _statCard(
                  'Bảo trì', '$maintenance', Icons.build_outlined, Colors.grey),
              _statCard('Cần dọn dẹp', '$needCleaning', Icons.cleaning_services,
                  Colors.redAccent),
              _statCard('Đặt phòng hôm nay', '${todayBookings.length}',
                  Icons.today, Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: AppTheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng doanh thu',
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                    ],
                  ),
                  Text(Formatters.currency(revenue),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Đặt phòng gần đây',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (provider.bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: Text('Chưa có đặt phòng nào',
                      style: TextStyle(color: Colors.grey))),
            )
          else
            ...provider.bookings.reversed.take(5).map((b) => Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.event_note, color: AppTheme.primary),
                    title: Text(b.roomName),
                    subtitle: Text(
                        '${b.userName} • ${Formatters.date(b.checkIn)} → ${Formatters.date(b.checkOut)}'),
                    trailing: Text(Formatters.currency(b.total)),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 26),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

