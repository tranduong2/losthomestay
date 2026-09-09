import '../models/room_model.dart';
import '../models/user_model.dart';
import '../models/discount_model.dart';
import '../models/booking_model.dart';

class MockData {
  /// Fresh records with dates relative to the day the app opens.
  static List<BookingModel> createBookings({DateTime? now}) {
    final clock = now ?? DateTime.now();
    final catalog = rooms;
    final available =
        catalog.where((r) => r.status == RoomStatus.available).toList();
    final customers = users.where((u) => u.role == UserRole.customer).toList();
    return List.generate(30, (i) {
      final room = i == 18
          ? catalog.firstWhere((r) => r.id == 'R003')
          : available[i % available.length];
      final user = i % 3 == 0
          ? customers.firstWhere((u) => u.id == 'U001')
          : customers[i % customers.length];
      final offset = i < 18 ? -80 + i * 4 : (i == 18 ? -1 : (i - 18) * 2);
      final checkIn = DateTime(clock.year, clock.month, clock.day + offset);
      final nights = i == 18 ? 3 : 2 + i % 3;
      final subtotal = room.pricePerNight * nights;
      final percent = i % 4 == 0 ? 10.0 : 0.0;
      return BookingModel(
        id: 'DEMO-BK${(i + 1).toString().padLeft(3, '0')}',
        roomId: room.id,
        roomName: room.name,
        userId: user.id,
        userName: user.name,
        contactPhone: user.phone,
        checkIn: checkIn,
        checkOut: DateTime(checkIn.year, checkIn.month, checkIn.day + nights),
        guests: room.maxGuests > 4 ? 4 : room.maxGuests,
        subtotal: subtotal,
        discountPercent: percent,
        total: subtotal * (100 - percent) / 100,
        discountCode: percent > 0 ? 'WELCOME10' : null,
        createdAt: checkIn.subtract(const Duration(days: 30)),
        paymentMethod: const [
          'Thẻ tín dụng/ghi nợ',
          'Ví MoMo',
          'Chuyển khoản ngân hàng',
          'Thanh toán tại homestay'
        ][i % 4],
        status: i < 18
            ? BookingStatus.completed
            : i >= 28
                ? BookingStatus.cancelled
                : i.isOdd
                    ? BookingStatus.pending
                    : BookingStatus.confirmed,
      );
    });
  }

  static List<RoomModel> get rooms => [
        RoomModel(
          id: 'R001',
          name: 'Phòng Garden View',
          description:
              'Phòng view vườn yên tĩnh, thiết kế mộc mạc gần gũi thiên nhiên. Phù hợp cho cặp đôi hoặc gia đình nhỏ muốn nghỉ dưỡng thư giãn.',
          pricePerNight: 450000,
          imageUrl: 'https://picsum.photos/seed/room1/800/500',
          maxGuests: 2,
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bãi đỗ xe'],
          status: RoomStatus.available,
          cleaningStatus: CleaningStatus.clean,
          rating: 4.8,
        ),
        RoomModel(
          id: 'R002',
          name: 'Phòng Lake View',
          description:
              'Phòng hướng hồ, ban công riêng ngắm hoàng hôn tuyệt đẹp. Nội thất hiện đại, đầy đủ tiện nghi cho kỳ nghỉ đáng nhớ.',
          pricePerNight: 650000,
          imageUrl: 'https://picsum.photos/seed/room2/800/500',
          maxGuests: 3,
          amenities: ['Wifi miễn phí', 'Ban công', 'Bồn tắm', 'Minibar'],
          status: RoomStatus.available,
          cleaningStatus: CleaningStatus.clean,
          rating: 4.9,
        ),
        RoomModel(
          id: 'R003',
          name: 'Bungalow Gia Đình',
          description:
              'Bungalow rộng rãi dành cho gia đình đông người, có phòng khách riêng và bếp nhỏ tiện nghi.',
          pricePerNight: 950000,
          imageUrl: 'https://picsum.photos/seed/room3/800/500',
          maxGuests: 5,
          amenities: ['Wifi miễn phí', 'Bếp riêng', '2 phòng ngủ', 'Sân vườn'],
          status: RoomStatus.occupied,
          cleaningStatus: CleaningStatus.dirty,
          rating: 4.7,
        ),
        RoomModel(
          id: 'R004',
          name: 'Phòng Dorm Tiết Kiệm',
          description:
              'Phòng dạng dorm giá tốt, phù hợp cho khách du lịch bụi, sinh viên muốn tiết kiệm chi phí.',
          pricePerNight: 180000,
          imageUrl: 'https://picsum.photos/seed/room4/800/500',
          maxGuests: 1,
          amenities: ['Wifi miễn phí', 'Tủ khóa cá nhân', 'Quạt trần'],
          status: RoomStatus.available,
          cleaningStatus: CleaningStatus.cleaning,
          rating: 4.3,
        ),
        RoomModel(
          id: 'R005',
          name: 'Villa Riêng Tư',
          description:
              'Villa nguyên căn riêng tư tuyệt đối, có hồ bơi mini, sân BBQ, thích hợp cho nhóm bạn hoặc gia đình lớn.',
          pricePerNight: 1500000,
          imageUrl: 'https://picsum.photos/seed/room5/800/500',
          maxGuests: 8,
          amenities: [
            'Hồ bơi riêng',
            'Sân BBQ',
            'Wifi tốc độ cao',
            'Bãi đỗ xe'
          ],
          status: RoomStatus.maintenance,
          cleaningStatus: CleaningStatus.dirty,
          rating: 5.0,
        ),
        ...additionalRooms,
      ];

  static List<RoomModel> get additionalRooms => [
        RoomModel(
          id: 'R006',
          name: 'Đồi Thông',
          description:
              'Đồi Thông có không gian thoáng sáng, nội thất ấm cúng và khu vực nghỉ ngơi riêng. Phù hợp cho cặp đôi hoặc khách nghỉ dưỡng với sức chứa 2 khách.',
          pricePerNight: 520000,
          maxGuests: 2,
          rating: 4.8,
          imageUrl: 'https://picsum.photos/seed/room6/800/500',
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bàn làm việc'],
        ),
        RoomModel(
          id: 'R007',
          name: 'Sunset Balcony',
          description:
              'Sunset Balcony có không gian thoáng sáng, nội thất ấm cúng và khu vực nghỉ ngơi riêng. Phù hợp cho cặp đôi hoặc khách nghỉ dưỡng với sức chứa 3 khách.',
          pricePerNight: 780000,
          maxGuests: 3,
          rating: 4.8,
          imageUrl: 'https://picsum.photos/seed/room7/800/500',
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bàn làm việc'],
        ),
        RoomModel(
          id: 'R008',
          name: 'Bungalow Hoa Cẩm Tú',
          description:
              'Bungalow Hoa Cẩm Tú có không gian thoáng sáng, nội thất ấm cúng và khu vực nghỉ ngơi riêng. Phù hợp cho gia đình hoặc nhóm bạn với sức chứa 5 khách.',
          pricePerNight: 1100000,
          maxGuests: 5,
          rating: 4.8,
          imageUrl: 'https://picsum.photos/seed/room8/800/500',
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bếp riêng'],
        ),
        RoomModel(
          id: 'R009',
          name: 'Suite Panorama',
          description:
              'Suite Panorama có không gian thoáng sáng, nội thất ấm cúng và khu vực nghỉ ngơi riêng. Phù hợp cho gia đình hoặc nhóm bạn với sức chứa 8 khách.',
          pricePerNight: 1850000,
          maxGuests: 8,
          rating: 4.8,
          imageUrl: 'https://picsum.photos/seed/room9/800/500',
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bếp riêng'],
        ),
        RoomModel(
          id: 'R010',
          name: 'Gác Mái',
          description:
              'Gác Mái có không gian thoáng sáng, nội thất ấm cúng và khu vực nghỉ ngơi riêng. Phù hợp cho cặp đôi hoặc khách nghỉ dưỡng với sức chứa 2 khách.',
          pricePerNight: 390000,
          maxGuests: 2,
          rating: 4.8,
          imageUrl: 'https://picsum.photos/seed/room10/800/500',
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bàn làm việc'],
        ),
        RoomModel(
          id: 'R011',
          name: 'Studio Bên Vườn',
          description:
              'Studio Bên Vườn có không gian thoáng sáng, nội thất ấm cúng và khu vực nghỉ ngơi riêng. Phù hợp cho cặp đôi hoặc khách nghỉ dưỡng với sức chứa 3 khách.',
          pricePerNight: 690000,
          maxGuests: 3,
          rating: 4.8,
          imageUrl: 'https://picsum.photos/seed/room11/800/500',
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bàn làm việc'],
        ),
        RoomModel(
          id: 'R012',
          name: 'Villa An Nhiên',
          description:
              'Villa An Nhiên có không gian thoáng sáng, nội thất ấm cúng và khu vực nghỉ ngơi riêng. Phù hợp cho gia đình hoặc nhóm bạn với sức chứa 10 khách.',
          pricePerNight: 2200000,
          maxGuests: 10,
          rating: 4.8,
          imageUrl: 'https://picsum.photos/seed/room12/800/500',
          amenities: ['Wifi miễn phí', 'Điều hòa', 'Nước nóng', 'Bếp riêng'],
        ),
      ];

  static List<UserModel> get users => [
        ...List.generate(
            6,
            (i) => UserModel(
                  id: 'U00${i + 2}',
                  name: const [
                    'Trần Minh Anh',
                    'Lê Hoàng Nam',
                    'Phạm Thu Hà',
                    'Võ Gia Bảo',
                    'Đặng Ngọc Linh',
                    'Bùi Thanh Tùng'
                  ][i],
                  email: 'khach${i + 2}@example.com',
                  password: '123456',
                  phone: '090000000${i + 2}',
                  role: UserRole.customer,
                )),
        UserModel(
          id: 'U001',
          name: 'Nguyễn Văn A',
          email: 'khach@gmail.com',
          password: '123456',
          phone: '0901234567',
          role: UserRole.customer,
        ),
        UserModel(
          id: 'ADMIN01',
          name: 'Quản trị viên',
          email: 'admin@homestay.com',
          password: 'admin123',
          phone: '0909999999',
          role: UserRole.admin,
        ),
      ];

  static List<DiscountModel> get discounts => [
        DiscountModel(
          code: 'WELCOME10',
          percent: 10,
          expiry: DateTime.now().add(const Duration(days: 365)),
        ),
        DiscountModel(
          code: 'SUMMER20',
          percent: 20,
          expiry: DateTime.now().add(const Duration(days: 90)),
        ),
        DiscountModel(
          code: 'HOMESTAY50',
          percent: 50,
          expiry: DateTime.now().add(const Duration(days: 5)),
        ),
      ];
}
