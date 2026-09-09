import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../utils/formatters.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import 'booking_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final RoomModel room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final isAvailable = room.status == RoomStatus.available;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                room.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.house, size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(room.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      RoomStatusBadge(status: room.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${room.rating}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.people_outline,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Tối đa ${room.maxGuests} khách'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Formatters.currency(room.pricePerNight),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text('mỗi đêm', style: TextStyle(color: Colors.grey)),
                  const Divider(height: 32),
                  const Text('Mô tả',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(room.description,
                      style:
                          const TextStyle(height: 1.5, color: AppTheme.ink)),
                  const SizedBox(height: 20),
                  const Text('Tiện nghi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: room.amenities
                        .map((a) => Chip(
                              avatar: const Icon(Icons.check_circle,
                                  size: 16, color: AppTheme.primary),
                              label: Text(a),
                              backgroundColor:
                                  AppTheme.primary.withValues(alpha: 0.08),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            text: isAvailable ? 'Đặt phòng ngay' : 'Phòng hiện không khả dụng',
            onPressed: isAvailable
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BookingScreen(room: room)))
                : null,
          ),
        ),
      ),
    );
  }
}


