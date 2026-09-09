import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../models/discount_model.dart';
import '../../providers/app_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/booking_form_panel.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final RoomModel room;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;
  final int initialGuests;

  const BookingScreen({
    super.key,
    required this.room,
    this.initialCheckIn,
    this.initialCheckOut,
    this.initialGuests = 1,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late RoomModel _room;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  final _codeCtrl = TextEditingController();
  DiscountModel? _appliedDiscount;
  String? _discountMsg;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    final user = context.read<AppProvider>().currentUser;
    _name.text = user?.name ?? '';
    _phone.text = user?.phone ?? '';
    _checkIn = widget.initialCheckIn;
    _checkOut = widget.initialCheckOut;
    _guests = widget.initialGuests.clamp(1, _room.maxGuests);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  int get nights => (_checkIn != null && _checkOut != null)
      ? _checkOut!.difference(_checkIn!).inDays
      : 0;

  double get subtotal => nights * _room.pricePerNight;

  double get total =>
      subtotal - (subtotal * (_appliedDiscount?.percent ?? 0) / 100);

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: (_checkIn != null && _checkOut != null)
          ? DateTimeRange(start: _checkIn!, end: _checkOut!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _checkIn = range.start;
        _checkOut = range.end.isAfter(range.start)
            ? range.end
            : range.start.add(const Duration(days: 1));
      });
    }
  }

  void _applyDiscount() {
    final provider = context.read<AppProvider>();
    final discount = provider.validateDiscount(_codeCtrl.text);
    setState(() {
      if (discount != null) {
        _appliedDiscount = discount;
        _discountMsg =
            'Áp dụng thành công: giảm ${discount.percent.toStringAsFixed(0)}%';
      } else {
        _appliedDiscount = null;
        _discountMsg = 'Mã giảm giá không hợp lệ hoặc đã hết hạn';
      }
    });
  }

  void _continue() {
    if (nights <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vui lòng chọn ngày trả phòng sau ngày nhận phòng.')));
      return;
    }
    if (_room.status != RoomStatus.available) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Phòng này vừa hết. Vui lòng chọn phòng khác.')));
      return;
    }
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ngày nhận/trả phòng')));
      return;
    }
    if (_guests > _room.maxGuests) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phòng chỉ tối đa ${_room.maxGuests} khách')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentScreen(
        room: _room,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        guests: _guests,
        discount: _appliedDiscount,
        subtotal: subtotal,
        total: total,
        contactName: _name.text.trim(),
        contactPhone: _phone.text.trim(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => BookingFormPanel(
        room: _room,
        rooms: context.watch<AppProvider>().rooms,
        name: _name,
        phone: _phone,
        checkIn: _checkIn,
        checkOut: _checkOut,
        guests: _guests,
        nights: nights,
        total: total,
        onRoom: (room) => setState(() {
          _room = room;
          _guests = _guests.clamp(1, room.maxGuests);
        }),
        onGuests: (guests) => setState(() => _guests = guests),
        onDates: _pickDateRange,
        onContinue: _continue,
        discountCode: _codeCtrl,
        onDiscount: _applyDiscount,
        discountMessage: _discountMsg,
      );
}

