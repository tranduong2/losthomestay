import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/room_model.dart';
import '../../utils/formatters.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';

class AdminRoomsScreen extends StatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  RoomStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final rooms = provider.rooms
        .where((r) => _filter == null || r.status == _filter)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tình trạng phòng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Tất cả', null),
                  _filterChip('Trống', RoomStatus.available),
                  _filterChip('Đang ở', RoomStatus.occupied),
                  _filterChip('Bảo trì', RoomStatus.maintenance),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                room.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.house),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(room.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(Formatters.currency(room.pricePerNight),
                                      style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            RoomStatusBadge(status: room.status),
                            CleaningStatusBadge(status: room.cleaningStatus),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<RoomStatus>(
                                initialValue: room.status,
                                decoration: const InputDecoration(
                                  labelText: 'Cập nhật trạng thái',
                                  isDense: true,
                                ),
                                items: RoomStatus.values
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(_statusLabel(s)),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    provider.setRoomStatus(room.id, v);
                                  }
                                },
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
          ),
        ],
      ),
    );
  }

  String _statusLabel(RoomStatus s) {
    switch (s) {
      case RoomStatus.available:
        return 'Trống';
      case RoomStatus.occupied:
        return 'Đang ở';
      case RoomStatus.maintenance:
        return 'Bảo trì';
    }
  }

  Widget _filterChip(String label, RoomStatus? status) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.primary.withValues(alpha: 0.15),
        onSelected: (_) => setState(() => _filter = status),
      ),
    );
  }
}

