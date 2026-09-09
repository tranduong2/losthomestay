# Cozy Homestay - Ứng dụng đặt phòng Homestay (Flutter)

Ứng dụng demo đặt phòng homestay viết bằng Flutter, quản lý state bằng `provider`, dữ liệu mẫu (mock, lưu trong bộ nhớ — không có backend thật).

## Chức năng

### Phía khách hàng
- Đăng ký / Đăng nhập / Đăng xuất
- Trang chủ: danh sách phòng, tìm kiếm
- Xem chi tiết phòng (mô tả, tiện nghi, giá, đánh giá)
- Đặt phòng: chọn ngày nhận/trả, số khách
- Nhập & áp dụng mã giảm giá (thử: `WELCOME10`, `SUMMER20`, `HOMESTAY50`)
- Thanh toán (chọn phương thức: thẻ, ví MoMo, chuyển khoản, thanh toán tại homestay)
- Trang giới thiệu homestay
- Lịch sử đặt phòng của tôi (xem, hủy đặt phòng)
- Trang cá nhân

### Phía Admin
- Đăng nhập admin (tài khoản: `admin@homestay.com` / `admin123`)
- Bảng điều khiển: thống kê phòng trống/đang ở/bảo trì, doanh thu, đặt phòng gần đây
- Kiểm tra & cập nhật tình trạng phòng (trống / đang ở / bảo trì)
- Quản lý dọn phòng (đánh dấu: cần dọn / đang dọn / sạch sẽ)
- Lịch đặt phòng dạng calendar, xem đặt phòng theo từng ngày

## Tài khoản demo
| Vai trò | Email | Mật khẩu |
|---|---|---|
| Khách hàng | khach@gmail.com | 123456 |
| Admin | admin@homestay.com | admin123 |

## Cách chạy

1. Cài Flutter SDK (>= 3.19): https://docs.flutter.dev/get-started/install
2. Giải nén project, mở terminal tại thư mục gốc
3. Cài dependency:
   ```
   flutter pub get
   ```
4. Chạy ứng dụng (kết nối thiết bị/emulator trước):
   ```
   flutter run
   ```

## Cấu trúc thư mục

```
lib/
  models/        -> Room, User, Booking, Discount
  data/          -> Dữ liệu mẫu (mock_data.dart)
  providers/     -> AppProvider (quản lý toàn bộ state: auth, booking, phòng...)
  utils/         -> Theme, formatters (định dạng tiền tệ, ngày tháng)
  widgets/       -> Các widget dùng chung (room card, status badge, button...)
  screens/
    auth/        -> Đăng nhập, đăng ký
    customer/    -> Trang chủ, chi tiết phòng, đặt phòng, thanh toán, lịch sử...
    admin/       -> Dashboard, quản lý phòng, dọn phòng, lịch đặt phòng
```

## Lưu ý
- Đây là bản demo dùng dữ liệu mẫu lưu trong bộ nhớ (mất khi tắt app). Để dùng thật,
  cần nối với backend (Firebase, REST API,...) để lưu người dùng, phòng, đặt phòng.
- Ảnh phòng dùng ảnh ngẫu nhiên từ picsum.photos (cần internet để hiển thị).
- Phần thanh toán chỉ mô phỏng giao diện, chưa tích hợp cổng thanh toán thật (VNPay, Momo, Stripe...).

## Dữ liệu demo bổ sung
- 12 phòng, 7 khách hàng và 1 admin; 30 đơn đặt phòng với đủ 4 trạng thái.
- Ngày đặt phòng tự tính theo ngày mở app, có lịch sử và đơn sắp tới.
- Tài khoản bổ sung: khach2@example.com đến khach7@example.com / 123456.
- Dữ liệu tự nạp khi khởi động và chỉ lưu trong bộ nhớ; khởi động lại sẽ khôi phục bộ mẫu.

