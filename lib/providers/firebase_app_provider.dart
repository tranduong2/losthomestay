import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_provider.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/discount_model.dart';

class FirebaseAppProvider extends AppProvider {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  StreamSubscription? _roomSub, _authSub, _bookingSub;
  int _generation = 0;
  bool _disposed = false;
  bool _registering = false;
  @override
  bool get isLive => true;

  FirebaseAppProvider({FirebaseAuth? auth, FirebaseFirestore? db})
      : auth = auth ?? FirebaseAuth.instance,
        db = db ?? FirebaseFirestore.instance {
    rooms.clear();
    users.clear();
    discounts.clear();
    bookings.clear();
    loading = true;
    _roomSub = this.db.collection('rooms').snapshots().listen((snapshot) {
      try {
        final result =
            snapshot.docs.map((d) => roomFromData(d.id, d.data())).toList();
        rooms
          ..clear()
          ..addAll(result);
        loading = false;
        _notify();
      } catch (e) {
        _error(e);
      }
    }, onError: _error);
    _authSub = this.auth.authStateChanges().listen((user) {
      if (!_registering) unawaited(_loadUser(user));
    }, onError: _error);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _error(Object e) {
    loading = false;
    lastError = messageFor(e);
    _notify();
  }

  static String messageFor(Object e) {
    if (e is FirebaseException) {
      return switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Email hoặc mật khẩu không đúng.',
        'email-already-in-use' => 'Email đã được đăng ký. Vui lòng đăng nhập.',
        'weak-password' => 'Mật khẩu cần ít nhất 6 ký tự.',
        'invalid-email' => 'Email không hợp lệ.',
        'operation-not-allowed' =>
          'Đăng nhập Email/Password chưa được bật trên Firebase.',
        'permission-denied' =>
          'Không có quyền thực hiện thao tác này. Vui lòng đăng nhập và thử lại.',
        'unavailable' ||
        'network-request-failed' =>
          'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.',
        'too-many-requests' => 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.',
        _ => 'Không thể lưu hoặc tải dữ liệu (${e.code}). Vui lòng thử lại.',
      };
    }
    return e is StateError
        ? e.message.toString()
        : 'Không thể xử lý dữ liệu. Vui lòng thử lại.';
  }

  Future<void> _loadUser(User? user) async {
    final generation = ++_generation;
    await _bookingSub?.cancel();
    currentUser = null;
    bookings.clear();
    _notify();
    if (user == null) return;
    try {
      final profile = await db.collection('users').doc(user.uid).get();
      final token = await user.getIdTokenResult();
      if (_disposed ||
          generation != _generation ||
          auth.currentUser?.uid != user.uid) return;
      final data = profile.data() ?? {};
      currentUser = UserModel(
          id: user.uid,
          name: data['name'] as String? ?? user.displayName ?? 'Khách hàng',
          email: user.email ?? '',
          password: '',
          phone: data['phone'] as String? ?? '',
          role: token.claims?['admin'] == true
              ? UserRole.admin
              : UserRole.customer);
      Query<Map<String, dynamic>> query = db.collection('bookings');
      if (!isAdmin) query = query.where('userId', isEqualTo: user.uid);
      _bookingSub = query
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots()
          .listen((snapshot) {
        if (generation != _generation) return;
        try {
          final result = snapshot.docs
              .where((d) => d.data()['isDemo'] != true)
              .map((d) => bookingFromData(d.id, d.data()))
              .toList();
          bookings
            ..clear()
            ..addAll(result);
          _notify();
        } catch (e) {
          _error(e);
        }
      }, onError: _error);
      _notify();
    } catch (e) {
      if (generation == _generation) _error(e);
    }
  }

  @override
  Future<String?> login(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      await _loadUser(result.user);
      return currentUser == null
          ? (lastError ?? 'Không tải được hồ sơ.')
          : null;
    } catch (e) {
      return messageFor(e);
    }
  }

  @override
  Future<String?> register(
      String name, String email, String password, String phone) async {
    _registering = true;
    ++_generation;
    currentUser = null;
    bookings.clear();
    await _bookingSub?.cancel();
    try {
      final result = await auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final user = result.user!;
      await user.updateDisplayName(name.trim());
      await db.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': user.email,
        'phone': phone.trim(),
        'role': 'customer',
      });
      await auth.signOut();
      _notify();
      return null;
    } catch (e) {
      // Firebase automatically signs in after account creation. Never keep
      // that temporary session, including when saving the profile fails.
      try {
        await auth.signOut();
      } catch (signOutError) {
        _error(signOutError);
      }
      return messageFor(e);
    } finally {
      _registering = false;
    }
  }

  @override
  void logout() {
    ++_generation;
    currentUser = null;
    bookings.clear();
    unawaited(_bookingSub?.cancel());
    _notify();
    unawaited(auth.signOut().catchError(_error));
  }

  @override
  Future<DiscountModel?> validateDiscount(String code) async {
    if (auth.currentUser == null)
      throw StateError('Vui lòng đăng nhập để áp dụng mã giảm giá.');
    final snapshot =
        await db.collection('discounts').doc(code.trim().toUpperCase()).get();
    final data = snapshot.data();
    if (data == null) return null;
    final discount = DiscountModel(
        code: snapshot.id,
        percent: (data['percent'] as num).toDouble(),
        expiry: (data['expiry'] as Timestamp).toDate(),
        active: data['active'] == true);
    return discount.isValid ? discount : null;
  }

  @override
  Future<BookingModel> createBooking(
      {required RoomModel room,
      required DateTime checkIn,
      required DateTime checkOut,
      required int guests,
      DiscountModel? discount,
      required String paymentMethod,
      String? contactName,
      String? contactPhone}) async {
    final user = currentUser;
    if (user == null)
      throw StateError('Vui lòng đăng nhập trước khi đặt phòng.');
    // Normalize dates to midnight in Vietnam, independent of browser timezone.
    final start = DateTime.utc(checkIn.year, checkIn.month, checkIn.day)
        .subtract(const Duration(hours: 7));
    final end = DateTime.utc(checkOut.year, checkOut.month, checkOut.day)
        .subtract(const Duration(hours: 7));
    final nights = end.difference(start).inDays;
    if (nights < 1 || nights > 30)
      throw StateError('Mỗi yêu cầu đặt từ 1 đến 30 đêm.');
    final latest = await db.collection('rooms').doc(room.id).get();
    final fresh = roomFromData(latest.id, latest.data()!);
    if (fresh.status != RoomStatus.available ||
        guests < 1 ||
        guests > fresh.maxGuests) {
      throw StateError(
          'Phòng hoặc số khách không còn phù hợp. Vui lòng chọn lại.');
    }
    final validDiscount =
        discount == null ? null : await validateDiscount(discount.code);
    if (discount != null && validDiscount == null)
      throw StateError('Mã giảm giá đã hết hạn. Vui lòng chọn lại.');
    final subtotal = fresh.pricePerNight * nights;
    final percent = validDiscount?.percent ?? 0.0;
    final data = <String, dynamic>{
      'roomId': room.id,
      'roomName': fresh.name,
      'userId': user.id,
      'userName': (contactName ?? user.name).trim(),
      'contactPhone': (contactPhone ?? user.phone).trim(),
      'checkIn': Timestamp.fromDate(start),
      'checkOut': Timestamp.fromDate(end),
      'guests': guests,
      'subtotal': subtotal,
      'discountPercent': percent,
      'total': subtotal * (100 - percent) / 100,
      'discountCode': validDiscount?.code,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'paymentMethod': paymentMethod,
    };
    final ref = db.collection('bookings').doc();
    await ref.set(data);
    return bookingFromData(ref.id, {...data, 'createdAt': Timestamp.now()});
  }

  Future<void> _save(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      _error(e);
    }
  }

  @override
  void cancelBooking(String id) {
    unawaited(_save(() =>
        db.collection('bookings').doc(id).update({'status': 'cancelled'})));
  }

  @override
  void setRoomStatus(String id, RoomStatus status) {
    unawaited(_save(
        () => db.collection('rooms').doc(id).update({'status': status.name})));
  }

  @override
  void setCleaningStatus(String id, CleaningStatus status) {
    unawaited(_save(() => db
        .collection('rooms')
        .doc(id)
        .update({'cleaningStatus': status.name})));
  }

  @override
  void updateBookingStatus(String id, BookingStatus status) {
    unawaited(_save(() async {
      if (!isAdmin) throw StateError('Cần quyền quản trị.');
      // Serialize confirmations per room; trusted admins check overlapping confirmed stays.
      final ref = db.collection('bookings').doc(id);
      final initial = await ref.get();
      final roomRef =
          db.collection('rooms').doc(initial.data()!['roomId'] as String);
      await db.runTransaction((tx) async {
        final booking = (await tx.get(ref)).data()!;
        final roomData = (await tx.get(roomRef)).data()!;
        if (status == BookingStatus.confirmed) {
          if (booking['status'] != 'pending')
            throw StateError('Chỉ xác nhận đơn đang chờ.');
          final others = await db
              .collection('bookings')
              .where('roomId', isEqualTo: booking['roomId'])
              .get();
          final start = (booking['checkIn'] as Timestamp).toDate();
          final end = (booking['checkOut'] as Timestamp).toDate();
          for (final other in others.docs) {
            final d = other.data();
            if (other.id != id &&
                d['status'] == 'confirmed' &&
                d['isDemo'] != true &&
                (d['checkIn'] as Timestamp).toDate().isBefore(end) &&
                (d['checkOut'] as Timestamp).toDate().isAfter(start)) {
              throw StateError('Phòng đã có đơn xác nhận trùng ngày.');
            }
          }
        }
        tx.update(ref, {'status': status.name});
        tx.update(roomRef, {
          'bookingVersion': ((roomData['bookingVersion'] as num?) ?? 0) + 1,
          if (status == BookingStatus.completed) 'cleaningStatus': 'dirty'
        });
      });
    }));
  }

  @override
  Future<void> sendContact(
      String name, String email, String phone, String message) async {
    if (currentUser == null)
      throw StateError('Vui lòng đăng nhập trước khi gửi liên hệ.');
    await db.collection('contact_requests').add({
      'userId': currentUser!.id,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'message': message.trim(),
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  List<BookingModel> bookingsOnDate(DateTime date) => bookings.where((b) {
        final day = DateTime(date.year, date.month, date.day);
        final start = DateTime(b.checkIn.year, b.checkIn.month, b.checkIn.day);
        final end = DateTime(b.checkOut.year, b.checkOut.month, b.checkOut.day);
        return b.status != BookingStatus.cancelled &&
            !day.isBefore(start) &&
            day.isBefore(end);
      }).toList();
  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _roomSub?.cancel();
    _authSub?.cancel();
    _bookingSub?.cancel();
    super.dispose();
  }
}

RoomModel roomFromData(String id, Map<String, dynamic> d) => RoomModel(
    id: id,
    name: d['name'] as String,
    description: d['description'] as String,
    pricePerNight: (d['pricePerNight'] as num).toDouble(),
    imageUrl: d['imageUrl'] as String,
    maxGuests: (d['maxGuests'] as num).toInt(),
    amenities: List<String>.from(d['amenities'] as List),
    status: RoomStatus.values.byName(d['status'] as String),
    cleaningStatus: CleaningStatus.values.byName(d['cleaningStatus'] as String),
    rating: (d['rating'] as num).toDouble());

BookingModel bookingFromData(String id, Map<String, dynamic> d) {
  DateTime date(String key) =>
      (d[key] as Timestamp).toDate().toUtc().add(const Duration(hours: 7));
  return BookingModel(
      id: id,
      roomId: d['roomId'] as String,
      roomName: d['roomName'] as String,
      userId: d['userId'] as String,
      userName: d['userName'] as String,
      contactPhone: d['contactPhone'] as String?,
      checkIn: date('checkIn'),
      checkOut: date('checkOut'),
      guests: (d['guests'] as num).toInt(),
      subtotal: (d['subtotal'] as num).toDouble(),
      discountPercent: (d['discountPercent'] as num).toDouble(),
      total: (d['total'] as num).toDouble(),
      discountCode: d['discountCode'] as String?,
      createdAt: d['createdAt'] == null ? DateTime.now() : date('createdAt'),
      status: BookingStatus.values.byName(d['status'] as String),
      paymentMethod: d['paymentMethod'] as String);
}
