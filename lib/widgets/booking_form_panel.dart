import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../utils/formatters.dart';
import '../screens/auth/login_screen.dart';

class BookingFormPanel extends StatefulWidget {
  const BookingFormPanel(
      {super.key,
      required this.room,
      required this.rooms,
      required this.name,
      required this.phone,
      required this.checkIn,
      required this.checkOut,
      required this.guests,
      required this.nights,
      required this.total,
      required this.onRoom,
      required this.onGuests,
      required this.onDates,
      required this.onContinue,
      required this.discountCode,
      required this.onDiscount,
      required this.discountMessage});
  final RoomModel room;
  final List<RoomModel> rooms;
  final TextEditingController name, phone, discountCode;
  final DateTime? checkIn, checkOut;
  final int guests, nights;
  final double total;
  final ValueChanged<RoomModel> onRoom;
  final ValueChanged<int> onGuests;
  final VoidCallback onDates, onContinue, onDiscount;
  final String? discountMessage;
  @override
  State<BookingFormPanel> createState() => _BookingFormPanelState();
}

class _BookingFormPanelState extends State<BookingFormPanel> {
  final _form = GlobalKey<FormState>();
  static const bg = Color(0xFF0B142B),
      panel = Color(0xFF142544),
      muted = Color(0xFFB5C7E3),
      accent = Color(0xFF7DD3FC),
      line = Color(0xFF334F78);
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(primary: accent, surface: panel),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panel,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: line)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: line)),
        ));
    return Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: bg,
              foregroundColor: Colors.white,
              title: const Text('LOST ĐÀ LẠT',
                  style: TextStyle(
                      fontFamily: 'serif', fontWeight: FontWeight.bold))),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1220),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HOÀN TẤT',
                              style: TextStyle(
                                  color: accent,
                                  letterSpacing: 4,
                                  fontSize: 12)),
                          const SizedBox(height: 14),
                          const Text('Đặt phòng',
                              style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold)),
                          Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Bạn có thể ',
                                    style: TextStyle(color: muted)),
                                TextButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen())),
                                    child: const Text('đăng nhập')),
                                const Text(
                                    'để thanh toán và lưu lịch sử đặt phòng.',
                                    style: TextStyle(color: muted)),
                              ]),
                          const SizedBox(height: 38),
                          LayoutBuilder(
                              builder: (context, constraints) => constraints
                                          .maxWidth >=
                                      900
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Expanded(flex: 2, child: _fields()),
                                          const SizedBox(width: 40),
                                          Expanded(child: _summary())
                                        ])
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                          _fields(),
                                          const SizedBox(height: 24),
                                          _summary()
                                        ])),
                        ]))),
          ),
        ));
  }

  Widget _field(String label, Widget child) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: muted, fontSize: 16)),
        const SizedBox(height: 8),
        child
      ]);
  Widget _pair(Widget a, Widget b) => LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 520
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: a),
              const SizedBox(width: 20),
              Expanded(child: b)
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [a, const SizedBox(height: 20), b]));
  Widget _date(String label, DateTime? date) => _field(
      label,
      InkWell(
          onTap: widget.onDates,
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
              decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
              child:
                  Text(date == null ? 'dd/mm/yyyy' : Formatters.date(date)))));
  Widget _fields() {
    final rooms = <String, RoomModel>{
      widget.room.id: widget.room,
      for (final room in widget.rooms)
        if (room.status == RoomStatus.available) room.id: room
    }.values;
    return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: panel,
            border: Border.all(color: line),
            borderRadius: BorderRadius.circular(24)),
        child: Form(
            key: _form,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(
                      'Chọn phòng',
                      DropdownButtonFormField<String>(
                          initialValue: widget.room.id,
                          isExpanded: true,
                          items: rooms
                              .map((r) => DropdownMenuItem(
                                  value: r.id,
                                  child: Text(
                                      '${r.name} – ${Formatters.currency(r.pricePerNight)}',
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (id) => widget
                              .onRoom(rooms.firstWhere((r) => r.id == id)))),
                  const SizedBox(height: 22),
                  _pair(
                      _field(
                          'Họ và tên',
                          TextFormField(
                              controller: widget.name,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Vui lòng nhập họ và tên'
                                  : null)),
                      _field(
                          'Số điện thoại',
                          TextFormField(
                              controller: widget.phone,
                              keyboardType: TextInputType.phone,
                              validator: (v) => RegExp(r'^\+?[0-9 ()-]{8,20}$')
                                      .hasMatch(v?.trim() ?? '')
                                  ? null
                                  : 'Số điện thoại không hợp lệ'))),
                  const SizedBox(height: 22),
                  _pair(_date('Ngày nhận phòng', widget.checkIn),
                      _date('Ngày trả phòng', widget.checkOut)),
                  const SizedBox(height: 22),
                  _field(
                      'Số lượng khách',
                      DropdownButtonFormField<int>(
                          key: ValueKey('${widget.room.id}-${widget.guests}'),
                          initialValue: widget.guests,
                          items: List.generate(
                              widget.room.maxGuests,
                              (i) => DropdownMenuItem(
                                  value: i + 1, child: Text('${i + 1}'))),
                          onChanged: (v) => widget.onGuests(v!))),
                  Material(
                      color: panel,
                      child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Mã giảm giá',
                              style: TextStyle(color: muted)),
                          children: [
                            Row(children: [
                              Expanded(
                                  child: TextField(
                                      controller: widget.discountCode,
                                      decoration: const InputDecoration(
                                          hintText: 'WELCOME10'))),
                              TextButton(
                                  onPressed: widget.onDiscount,
                                  child: const Text('Áp dụng'))
                            ]),
                            if (widget.discountMessage != null)
                              Text(widget.discountMessage!,
                                  style: const TextStyle(color: accent)),
                          ])),
                  const SizedBox(height: 22),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(colors: [
                                Color(0xFF235DA8),
                                Color(0xFF12648A)
                              ])),
                          child: FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 22)),
                              onPressed: () {
                                if (_form.currentState!.validate()) {
                                  widget.onContinue();
                                }
                              },
                              child: const Text('Xác nhận đặt phòng',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))))),
                  const SizedBox(height: 12),
                  const Text('Tiếp tục đến bước thanh toán.',
                      style: TextStyle(color: muted, fontSize: 12)),
                ])));
  }

  Widget _summary() => Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: panel,
          border: Border.all(color: line),
          borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
            aspectRatio: 2,
            child: Image.network(widget.room.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFF080F22),
                    child: Center(child: Icon(Icons.bed_outlined, size: 48))))),
        Padding(
            padding: const EdgeInsets.all(28),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.room.name,
                  style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                  widget.nights > 0
                      ? '${Formatters.currency(widget.room.pricePerNight)} × ${widget.nights} đêm'
                      : '${Formatters.currency(widget.room.pricePerNight)} / đêm',
                  style: const TextStyle(color: muted)),
              const Divider(height: 30, color: line),
              Text.rich(TextSpan(
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  children: [
                    const TextSpan(text: 'Tổng: '),
                    TextSpan(
                        text: widget.nights > 0
                            ? Formatters.currency(widget.total)
                            : 'Chọn ngày lưu trú',
                        style: const TextStyle(color: accent))
                  ])),
            ])),
      ]));
}

