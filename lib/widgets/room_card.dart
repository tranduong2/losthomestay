import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAvailable = room.status == RoomStatus.available;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    room.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child:
                          const Icon(Icons.house, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.white : Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? 'Còn phòng' : 'Hết phòng',
                      style: TextStyle(
                          color: isAvailable ? AppTheme.primary : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(room.name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700))),
                    const Icon(Icons.arrow_outward_rounded,
                        size: 18, color: AppTheme.primary)
                  ]),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${room.rating}'),
                      const SizedBox(width: 12),
                      const Icon(Icons.people_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Tối đa ${room.maxGuests} khách'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: Formatters.currency(room.pricePerNight),
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    const TextSpan(
                        text: '  / đêm',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12))
                  ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

