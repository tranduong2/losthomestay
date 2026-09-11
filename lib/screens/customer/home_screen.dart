import '../../widgets/section_pager.dart';
import '../../widgets/rooms_catalog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/zoomable_network_image.dart';

import 'booking_screen.dart';
import 'room_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialSection = 0});
  final int initialSection;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _contactName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactPhone = TextEditingController();
  final _contactMessage = TextEditingController();
  bool _sendingContact = false;
  @override
  void dispose() {
    _contactName.dispose();
    _contactEmail.dispose();
    _contactPhone.dispose();
    _contactMessage.dispose();
    super.dispose();
  }

  Future<void> _sendContact() async {
    if (_sendingContact) return;
    if (_contactName.text.trim().isEmpty ||
        !_contactEmail.text.contains('@') ||
        _contactMessage.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nhập họ tên, email và nội dung liên hệ.')));
      return;
    }
    setState(() => _sendingContact = true);
    try {
      await context.read<AppProvider>().sendContact(_contactName.text,
          _contactEmail.text, _contactPhone.text, _contactMessage.text);
      if (!mounted) return;
      _contactMessage.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã lưu liên hệ. Homestay sẽ phản hồi sớm.')));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Chưa gửi được. Hãy đăng nhập, kiểm tra nội dung và thử lại.')));
    } finally {
      if (mounted) setState(() => _sendingContact = false);
    }
  }

  final _pager = GlobalKey<SectionPagerState>();
  final _roomsKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 2;
  String _roomType = 'Tất cả loại phòng';
  bool _searchApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pager.currentState?.goTo(widget.initialSection);
    });
  }

  void _go(GlobalKey key) {
    _pager.currentState?.goTo(key == _roomsKey
        ? 2
        : key == _aboutKey
            ? 3
            : 7);
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final date = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 730)),
        initialDate: isCheckIn
            ? _checkIn ?? DateTime.now()
            : _checkOut ??
                (_checkIn ?? DateTime.now()).add(const Duration(days: 1)));
    if (date != null)
      setState(() {
        if (isCheckIn)
          _checkIn = date;
        else
          _checkOut = date;
      });
  }

  void _searchRooms() {
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng chọn đầy đủ ngày nhận và trả phòng.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (!_checkOut!.isAfter(_checkIn!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ngày trả phòng phải sau ngày nhận phòng.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _searchApplied = true);
    _go(_roomsKey);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<AppProvider>().rooms;
    final visibleRooms = rooms.where((room) {
      final category = room.category;
      final matchesType =
          _roomType == 'Tất cả loại phòng' || _roomType == category;
      final matchesGuests = room.maxGuests >= _guests;
      final isAvailable = room.status == RoomStatus.available;
      return matchesType && (!_searchApplied || (matchesGuests && isAvailable));
    }).toList();
    return LayoutBuilder(builder: (context, constraints) {
      final mobile = constraints.maxWidth < 900;
      final contentWidth =
          (constraints.maxWidth - 32).clamp(0.0, 1200.0).toDouble();
      return Scaffold(
        body: Column(children: [
          Expanded(
              child: SectionPager(
            key: _pager,
            labels: const [
              'Khám phá',
              'Tìm phòng',
              'Phòng nổi bật',
              'Dịch vụ',
              'Ưu đãi',
              'Đánh giá',
              'Hình ảnh',
              'Liên hệ'
            ],
            children: [
              _hero(mobile, (constraints.maxHeight - 48).clamp(510.0, 1200.0)),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _searchBox(mobile, contentWidth)),
              RoomsCatalog(
                key: _roomsKey,
                rooms: visibleRooms,
                onDetails: (room) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RoomDetailScreen(room: room))),
                onBook: (room) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingScreen(
                            room: room,
                            initialCheckIn: _checkIn,
                            initialCheckOut: _checkOut,
                            initialGuests: _guests))),
              ),
              _benefits(mobile, contentWidth),
              _promotion(mobile, contentWidth),
              Column(children: [
                _sectionTitle('CẢM NHẬN', 'Khách hàng nói gì'),
                _testimonials(mobile, contentWidth),
                const SizedBox(height: 32),
              ]),
              Column(children: [
                _sectionTitle('KHÔNG GIAN', 'Thư viện hình ảnh'),
                _gallery(mobile, contentWidth),
                const SizedBox(height: 32),
              ]),
              Column(children: [
                _contact(mobile, contentWidth),
                _footer(mobile, contentWidth),
              ]),
            ],
          )),
        ]),
      );
    });
  }

  Widget _hero(bool mobile, double height) => SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Image.network(
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1800&q=90',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF101F3D))),
        const DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
          Color(0xB8081738),
          Color(0x7A102F59),
          Color(0xD907122B)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
        Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('MỘT KHOẢNG LẶNG GIỮA NGÀN THÔNG',
                      style: TextStyle(
                          color: Color(0xFF8ADFFF),
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  const SizedBox(height: 22),
                  Text('Chạm vào bình yên\ntại LOST Đà Lạt',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'serif',
                          color: AppTheme.ink,
                          fontWeight: FontWeight.bold,
                          fontSize: mobile ? 43 : 68,
                          height: 1.08)),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Text(
                          'Một nơi để chậm lại, hít thở mùi thông và thức giấc\ntrong màn sương dịu nhẹ của Đà Lạt.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: .92),
                              fontSize: mobile ? 16 : 19,
                              height: 1.45))),
                  const SizedBox(height: 28),
                  Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        FilledButton(
                            onPressed: () => _go(_roomsKey),
                            style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 27, vertical: 17),
                                shape: const StadiumBorder()),
                            child: const Text('Xem phòng')),
                        OutlinedButton(
                            onPressed: () => _go(_roomsKey),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 27, vertical: 17),
                                shape: const StadiumBorder()),
                            child: const Text('Đặt phòng ngay'))
                      ]),
                ]))),
      ]));

  Widget _searchBox(bool mobile, double width) => Container(
      width: width,
      padding: EdgeInsets.all(mobile ? 20 : 40),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                color: Color(0x26051025), blurRadius: 30, offset: Offset(0, 12))
          ]),
      child: Column(children: [
        Text('Tìm kiếm phòng',
            style: TextStyle(
                fontFamily: 'serif',
                fontSize: mobile ? 30 : 35,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 25),
        mobile
            ? Column(children: [
                _searchField(
                    'Ngày nhận phòng',
                    _checkIn == null
                        ? 'dd/mm/yyyy'
                        : Formatters.date(_checkIn!),
                    Icons.calendar_today_outlined,
                    () => _pickDate(true)),
                const SizedBox(height: 16),
                _searchField(
                    'Ngày trả phòng',
                    _checkOut == null
                        ? 'dd/mm/yyyy'
                        : Formatters.date(_checkOut!),
                    Icons.calendar_today_outlined,
                    () => _pickDate(false)),
                const SizedBox(height: 16),
                _selectField(),
                const SizedBox(height: 16),
                _roomTypeField(),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: _searchField(
                        'Ngày nhận phòng',
                        _checkIn == null
                            ? 'dd/mm/yyyy'
                            : Formatters.date(_checkIn!),
                        Icons.calendar_today_outlined,
                        () => _pickDate(true))),
                const SizedBox(width: 16),
                Expanded(
                    child: _searchField(
                        'Ngày trả phòng',
                        _checkOut == null
                            ? 'dd/mm/yyyy'
                            : Formatters.date(_checkOut!),
                        Icons.calendar_today_outlined,
                        () => _pickDate(false))),
                const SizedBox(width: 16),
                Expanded(child: _selectField()),
                const SizedBox(width: 16),
                Expanded(child: _roomTypeField()),
              ]),
        const SizedBox(height: 25),
        FilledButton.icon(
            onPressed: _searchRooms,
            icon: const Icon(Icons.search),
            label: const Text('Tìm phòng'),
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
                shape: const StadiumBorder()))
      ]));

  Widget _searchField(
          String label, String value, IconData icon, VoidCallback action) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
            onTap: action,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
                decoration: InputDecoration(suffixIcon: Icon(icon, size: 19)),
                child: Row(children: [
                  Icon(icon, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(value))
                ])))
      ]);
  Widget _selectField() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Số lượng khách',
            style:
                TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
            height: 57,
            decoration: BoxDecoration(
                color: const Color(0xFF142544),
                border: Border.all(color: const Color(0xFF334F78)),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              IconButton(
                  onPressed:
                      _guests > 1 ? () => setState(() => _guests--) : null,
                  icon: const Icon(Icons.remove_circle_outline)),
              Expanded(
                  child: Text('$_guests khách',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16))),
              IconButton(
                  onPressed: () => setState(() => _guests++),
                  icon: const Icon(Icons.add_circle_outline))
            ]))
      ]);

  Widget _roomTypeField() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Loại phòng',
            style:
                TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
            isExpanded: true,
            value: _roomType,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: const [
              'Tất cả loại phòng',
              'Deluxe',
              'Superior',
              'VIP',
              'Suite'
            ]
                .map((x) => DropdownMenuItem(
                    value: x, child: Text(x, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _roomType = v!))
      ]);

  Widget _sectionTitle(String eyebrow, String title, {Key? key}) => Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 34),
      child: Column(children: [
        Text(eyebrow,
            style: const TextStyle(
                letterSpacing: 4,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary)),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                fontFamily: 'serif', fontSize: 39, fontWeight: FontWeight.bold))
      ]));

  Widget _benefits(bool mobile, double width) => Container(
      key: _aboutKey,
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.symmetric(vertical: 72),
      width: double.infinity,
      color: const Color(0xFF10203C),
      child: Column(children: [
        _sectionTitle('ĐẶC QUYỀN', 'Tại sao chọn chúng tôi'),
        SizedBox(
            width: width,
            child: Wrap(
                spacing: 22,
                runSpacing: 18,
                alignment: WrapAlignment.center,
                children: [
                  _benefit(Icons.wifi_rounded, 'Wifi Free',
                      'Miễn phí toàn khách sạn'),
                  _benefit(Icons.breakfast_dining_outlined, 'Ăn sáng',
                      'Buffet miễn phí mỗi sáng'),
                  _benefit(
                      Icons.pool_outlined, 'Hồ bơi', 'Hồ bơi cao cấp vô cực'),
                  _benefit(Icons.directions_car_outlined, 'Bãi xe',
                      'Bãi đỗ xe miễn phí')
                ]))
      ]));
  static Widget _benefit(IconData icon, String title, String subtitle) =>
      SizedBox(
          width: 320,
          child: _HoverLift(
              child: Card(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 35, horizontal: 16),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 35,
                            backgroundColor: AppTheme.primary,
                            child: Icon(icon, color: Colors.white, size: 31)),
                        const SizedBox(height: 22),
                        Text(title,
                            style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(subtitle,
                            style: const TextStyle(color: AppTheme.muted),
                            textAlign: TextAlign.center)
                      ])))));

  Widget _promotion(bool mobile, double width) => Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 82),
      padding: EdgeInsets.symmetric(vertical: mobile ? 54 : 74, horizontal: 20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF101F3D), Color(0xFF16466E)]),
          borderRadius: BorderRadius.circular(28)),
      child: Column(children: [
        const Text('ƯU ĐÃI DÀNH RIÊNG CHO KỲ NGHỈ',
            style: TextStyle(
                color: Color(0xFF91DAFF),
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                fontSize: 11)),
        const SizedBox(height: 20),
        Text('Ở 3 đêm, ưu đãi 30%',
            style: TextStyle(
                fontFamily: 'serif',
                color: AppTheme.ink,
                fontWeight: FontWeight.bold,
                fontSize: mobile ? 48 : 72)),
        const SizedBox(height: 12),
        const Text(
            'Đặt trực tiếp để nhận mức giá tốt nhất, bữa sáng tại phòng\nvà một món quà nhỏ mang hương vị Đà Lạt.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 17)),
        const SizedBox(height: 28),
        FilledButton(
            onPressed: () => _go(_roomsKey),
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.ink,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
                shape: const StadiumBorder()),
            child: const Text('Đặt phòng ngay'))
      ]));

  Widget _testimonials(bool mobile, double width) => SizedBox(
      width: width,
      child: Wrap(spacing: 28, runSpacing: 20, children: [
        _quote(
            '“Dịch vụ rất tuyệt vời, nhân viên thân thiện.”', 'Nguyễn Văn A'),
        _quote('“Phòng sạch sẽ, giá hợp lý.”', 'Trần Thị B'),
        _quote(
            '“View biển buổi sáng đẹp không tưởng, sẽ quay lại.”', 'Lê Minh C')
      ]));
  static Widget _quote(String quote, String name) => SizedBox(
      width: 480,
      child: _HoverLift(
          child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('★★★★★',
                            style: TextStyle(
                                color: AppTheme.primary,
                                letterSpacing: 2,
                                fontSize: 20)),
                        const SizedBox(height: 20),
                        Text(quote,
                            style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 21,
                                height: 1.4)),
                        const SizedBox(height: 22),
                        Text(name,
                            style: const TextStyle(
                                color: AppTheme.muted,
                                fontWeight: FontWeight.bold))
                      ])))));

  Widget _gallery(bool mobile, double width) {
    const images = [
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1551218808-94e220e084d2?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1601918774946-25832a4be0d6?auto=format&fit=crop&w=900&q=85'
    ];
    return SizedBox(
        width: width,
        child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: images
                .asMap()
                .entries
                .map((entry) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                        width: mobile ? width : (width - 40) / 3,
                        height: mobile ? 220 : 290,
                        child: ZoomableNetworkImage(
                            imageUrl: entry.value,
                            heroTag: 'gallery-image-${entry.key}'))))
                .toList()));
  }

  Widget _contact(bool mobile, double width) => Container(
      key: _contactKey,
      padding: const EdgeInsets.only(top: 100, bottom: 90),
      child: Container(
          width: mobile ? width : 960,
          padding: EdgeInsets.all(mobile ? 24 : 50),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF334F78)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 25,
                    offset: Offset(0, 10))
              ]),
          child: Column(children: [
            const Text('HỖ TRỢ 24/7',
                style: TextStyle(
                    color: AppTheme.primary,
                    letterSpacing: 4,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Liên hệ nhanh',
                style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 37,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 28),
            TextField(
                controller: _contactName,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Họ và tên')),
            const SizedBox(height: 16),
            TextField(
                controller: _contactEmail,
                maxLength: 254,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(
                controller: _contactPhone,
                maxLength: 30,
                decoration: const InputDecoration(labelText: 'Số điện thoại')),
            const SizedBox(height: 16),
            TextField(
                controller: _contactMessage,
                maxLength: 2000,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Nội dung')),
            const SizedBox(height: 25),
            FilledButton(
                onPressed: _sendingContact ? null : _sendContact,
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16),
                    shape: const StadiumBorder()),
                child: const Text('Gửi liên hệ'))
          ])));

  Widget _footer(bool mobile, double width) => Container(
      width: double.infinity,
      color: const Color(0xFF101F3D),
      padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 16),
      child: Column(children: [
        SizedBox(
            width: width,
            child: Wrap(
                alignment:
                    mobile ? WrapAlignment.start : WrapAlignment.spaceBetween,
                spacing: 50,
                runSpacing: 34,
                children: const [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✦  LOST ĐÀ LẠT',
                            style: TextStyle(
                                color: AppTheme.ink,
                                fontFamily: 'serif',
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        SizedBox(
                            width: 280,
                            child: Text(
                                'Boutique hotel dành cho những tâm hồn muốn tìm lại nhịp sống chậm giữa ngàn thông.',
                                style: TextStyle(
                                    color: Color(0xFFBED0EA), height: 1.5)))
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thông tin liên hệ',
                            style: TextStyle(
                                color: AppTheme.ink,
                                fontFamily: 'serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        Text(
                            '⌖  Đà Lạt, Lâm Đồng, Việt Nam\n\n☎  1900 1234\n\n✉  stay@lostdalat.vn',
                            style: TextStyle(color: Color(0xFFBED0EA)))
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Liên kết',
                            style: TextStyle(
                                color: AppTheme.ink,
                                fontFamily: 'serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        Text(
                            'Danh sách phòng\n\nDịch vụ\n\nGiới thiệu\n\nTrang cá nhân',
                            style: TextStyle(color: Color(0xFFBED0EA)))
                      ])
                ])),
        const SizedBox(height: 35),
        const Divider(color: Color(0x55FFFFFF)),
        const SizedBox(height: 20),
        const Text('© 2026 LOST Đà Lạt. Find yourself in the mist.',
            style: TextStyle(color: Color(0xFFBED0EA)))
      ]));
}

class _HoverLift extends StatefulWidget {
  final Widget child;
  const _HoverLift({required this.child});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedSlide(
          offset: _hovered ? const Offset(0, -.025) : Offset.zero,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: _hovered ? 1.012 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      );
}
