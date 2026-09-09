import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../utils/formatters.dart';
import 'zoomable_network_image.dart';

class RoomsCatalog extends StatefulWidget {
  const RoomsCatalog(
      {super.key,
      required this.rooms,
      required this.onDetails,
      required this.onBook});
  final List<RoomModel> rooms;
  final ValueChanged<RoomModel> onDetails;
  final ValueChanged<RoomModel> onBook;

  @override
  State<RoomsCatalog> createState() => _RoomsCatalogState();
}

class _RoomsCatalogState extends State<RoomsCatalog> {
  String _type = 'Tất cả';
  double _maxPrice = 3500000;
  int _guests = 1;
  int _page = 0;
  String _resultKey = '';
  static const _surface = Color(0xFF142544);
  static const _muted = Color(0xFFB5C7E3);
  static const _accent = Color(0xFF7DD3FC);
  static const _border = Color(0xFF334F78);

  void _reset() => setState(() {
        _type = 'Tất cả';
        _maxPrice = 3500000;
        _guests = 1;
      });

  @override
  Widget build(BuildContext context) {
    final filtered = widget.rooms
        .where((room) =>
            (_type == 'Tất cả' || room.category == _type) &&
            room.pricePerNight <= _maxPrice &&
            room.maxGuests >= _guests)
        .toList();
    final resultKey =
        '$_type-$_maxPrice-$_guests-${filtered.map((r) => r.id).join(',')}';
    if (_resultKey != resultKey) {
      _resultKey = resultKey;
      _page = 0;
    }
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: const ColorScheme.dark(primary: _accent, surface: _surface),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: _border))),
    );
    return Theme(
        data: theme,
        child: DefaultTextStyle(
          style:
              const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          child: Container(
            color: const Color(0xFF0B142B),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PHÒNG NGHỈ',
                              style: TextStyle(
                                  color: _accent,
                                  fontSize: 11,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          const Text('Danh sách phòng',
                              style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15)),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 590),
                              child: const Text(
                                  'Lọc theo loại phòng, mức giá và số lượng khách để tìm phòng phù hợp nhất với bạn.',
                                  style: TextStyle(color: _muted))),
                          const SizedBox(height: 40),
                          LayoutBuilder(builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 850;
                            final results = _results(filtered);
                            return wide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        SizedBox(width: 256, child: _filters()),
                                        const SizedBox(width: 32),
                                        Expanded(child: results),
                                      ])
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                        _filters(),
                                        const SizedBox(height: 28),
                                        results,
                                      ]);
                          }),
                        ]))),
          ),
        ));
  }

  Widget _filters() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.tune, size: 18),
            SizedBox(width: 10),
            Text('Bộ lọc',
                style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 21,
                    fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 22),
          const Text('Loại phòng', style: TextStyle(color: _muted)),
          const SizedBox(height: 8),
          Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['Tất cả', 'Deluxe', 'Superior', 'VIP', 'Suite']
                  .map((type) => ChoiceChip(
                      label: Text(type),
                      selected: _type == type,
                      showCheckmark: false,
                      selectedColor: const Color(0xFF254E7B),
                      backgroundColor: _surface,
                      side: const BorderSide(color: _border),
                      labelStyle:
                          const TextStyle(fontSize: 12, color: Colors.white),
                      shape: const StadiumBorder(),
                      onSelected: (_) => setState(() => _type = type)))
                  .toList()),
          const SizedBox(height: 24),
          Text('Giá tối đa: ${Formatters.currency(_maxPrice)}',
              style: const TextStyle(color: _muted)),
          Slider(
              value: _maxPrice,
              min: 0,
              max: 3500000,
              divisions: 70,
              label: Formatters.currency(_maxPrice),
              onChanged: (value) => setState(() => _maxPrice = value)),
          const SizedBox(height: 16),
          const Text('Số khách tối thiểu', style: TextStyle(color: _muted)),
          const SizedBox(height: 8),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                IconButton(
                    tooltip: 'Giảm số khách',
                    onPressed:
                        _guests > 1 ? () => setState(() => _guests--) : null,
                    icon: const Icon(Icons.remove, size: 18)),
                Expanded(child: Text('$_guests', textAlign: TextAlign.center)),
                IconButton(
                    tooltip: 'Tăng số khách',
                    onPressed:
                        _guests < 20 ? () => setState(() => _guests++) : null,
                    icon: const Icon(Icons.add, size: 18)),
              ])),
          const SizedBox(height: 12),
          TextButton(onPressed: _reset, child: const Text('Đặt lại bộ lọc')),
        ]),
      );

  Widget _results(List<RoomModel> rooms) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
              liveRegion: true,
              child: Text('Tìm thấy ${rooms.length} phòng',
                  style: const TextStyle(color: _muted))),
          const SizedBox(height: 20),
          if (rooms.isEmpty)
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: _surface, borderRadius: BorderRadius.circular(18)),
                child: Column(children: [
                  const Icon(Icons.search_off, size: 40, color: _accent),
                  const SizedBox(height: 12),
                  const Text('Chưa tìm thấy phòng phù hợp'),
                  const SizedBox(height: 8),
                  const Text('Hãy thử thay đổi bộ lọc.',
                      style: TextStyle(color: _muted)),
                  TextButton(onPressed: _reset, child: const Text('Xóa bộ lọc'))
                ]))
          else
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 2 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 28) / columns;
              return Wrap(
                  spacing: 28,
                  runSpacing: 28,
                  children: rooms
                      .skip(_page * 4)
                      .take(4)
                      .map((room) => SizedBox(width: width, child: _card(room)))
                      .toList());
            }),
          if (rooms.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                    tooltip: 'Trang trước',
                    onPressed: _page > 0 ? () => setState(() => _page--) : null,
                    icon: const Icon(Icons.chevron_left)),
                Text('Trang ${_page + 1} / ${(rooms.length / 4).ceil()}'),
                IconButton(
                    tooltip: 'Trang sau',
                    onPressed: (_page + 1) * 4 < rooms.length
                        ? () => setState(() => _page++)
                        : null,
                    icon: const Icon(Icons.chevron_right)),
              ]),
            ),
        ],
      );

  Widget _card(RoomModel room) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            AspectRatio(
                aspectRatio: 4 / 3,
                child: ZoomableNetworkImage(
                    imageUrl: room.imageUrl, heroTag: 'catalog-${room.id}')),
            Positioned(
                top: 12,
                left: 12,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                            colors: [Color(0xFF245695), Color(0xFF153B70)])),
                    child: Text(room.category,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)))),
          ]),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name,
                        style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text.rich(TextSpan(
                        style: const TextStyle(color: _muted),
                        children: [
                          const TextSpan(text: 'Giá: '),
                          TextSpan(
                              text: Formatters.currency(room.pricePerNight),
                              style: const TextStyle(
                                  color: _accent, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' / đêm'),
                        ])),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.star, color: _accent, size: 17),
                      const SizedBox(width: 5),
                      Text('${room.rating}/5',
                          style: const TextStyle(color: _accent))
                    ]),
                    const SizedBox(height: 10),
                    Text(
                        '${room.maxGuests} khách · ${room.amenities.isEmpty ? 'Đầy đủ tiện nghi' : room.amenities.first}',
                        style: const TextStyle(color: _muted)),
                    const SizedBox(height: 20),
                    Wrap(spacing: 10, runSpacing: 8, children: [
                      OutlinedButton(
                          onPressed: () => widget.onDetails(room),
                          child: const Text('Chi tiết')),
                      FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1D5B9E),
                              foregroundColor: Colors.white),
                          onPressed: room.status == RoomStatus.available
                              ? () => widget.onBook(room)
                              : null,
                          child: Text(room.status == RoomStatus.available
                              ? 'Đặt phòng'
                              : room.status == RoomStatus.occupied
                                  ? 'Đã có khách'
                                  : 'Bảo trì')),
                    ]),
                  ])),
        ]),
      );
}

