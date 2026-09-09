import 'package:flutter/material.dart';
import '../models/room_model.dart';

class RoomStatusBadge extends StatelessWidget {
  final RoomStatus status;
  const RoomStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    switch (status) {
      case RoomStatus.available:
        color = Colors.green;
        label = 'Trống';
        break;
      case RoomStatus.occupied:
        color = Colors.orange;
        label = 'Đang ở';
        break;
      case RoomStatus.maintenance:
        color = Colors.grey;
        label = 'Bảo trì';
        break;
    }
    return _Badge(color: color, label: label);
  }
}

class CleaningStatusBadge extends StatelessWidget {
  final CleaningStatus status;
  const CleaningStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    switch (status) {
      case CleaningStatus.clean:
        color = Colors.blue;
        label = 'Sạch sẽ';
        break;
      case CleaningStatus.dirty:
        color = Colors.redAccent;
        label = 'Cần dọn';
        break;
      case CleaningStatus.cleaning:
        color = Colors.amber[800]!;
        label = 'Đang dọn';
        break;
    }
    return _Badge(color: color, label: label);
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final String label;
  const _Badge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

