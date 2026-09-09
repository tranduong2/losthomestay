import 'admin_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/room_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminCleaningScreen extends StatelessWidget {
  const AdminCleaningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final rooms = List<RoomModel>.from(provider.rooms)
      ..sort((a, b) => const [2, 0, 1][a.cleaningStatus.index]
          .compareTo(const [2, 0, 1][b.cleaningStatus.index]));

    return AdminPage(
      title: 'Dọn phòng',
      subtitle: 'Ưu tiên phòng cần dọn và cập nhật tiến độ ngay tại đây.',
      child: AdminGrid(
        count: rooms.length,
        builder: (context, index) {
          final room = rooms[index];
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
                        child: Text(room.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      CleaningStatusBadge(status: room.cleaningStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Trạng thái phòng: ${_roomStatusLabel(room.status)}',
                      style:
                          const TextStyle(color: AppTheme.muted, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: room.cleaningStatus == CleaningStatus.dirty
                              ? () => provider.setCleaningStatus(
                                  room.id, CleaningStatus.cleaning)
                              : null,
                          icon: const Icon(Icons.cleaning_services_outlined,
                              size: 18),
                          label: const Text('Bắt đầu dọn'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary),
                          onPressed: room.cleaningStatus != CleaningStatus.clean
                              ? () => provider.setCleaningStatus(
                                  room.id, CleaningStatus.clean)
                              : null,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Hoàn tất'),
                        ),
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

  String _roomStatusLabel(RoomStatus s) {
    switch (s) {
      case RoomStatus.available:
        return 'Trống';
      case RoomStatus.occupied:
        return 'Đang có khách';
      case RoomStatus.maintenance:
        return 'Bảo trì';
    }
  }
}
