# Firebase cho Cozy Homestay

Đã triển khai rules, indexes và nạp 12 phòng, 3 mã giảm giá vào project `lost-31a48`, database `(default)`, vùng `nam5` ngày 10/09/2026. Đã đọc lại và xác minh đủ 15 document khớp dữ liệu mẫu. Collections users/bookings sẽ xuất hiện khi có document đầu tiên. Chưa kết nối AppProvider với Firebase: website vẫn chạy demo trong bộ nhớ.

## Các bảng (collections)

Document ID là khóa, không cần lưu thêm trường `id`.

| Collection / ID | Trường | Kiểu dữ liệu |
|---|---|---|
| rooms / R001 | name, description, imageUrl | string |
| | pricePerNight, maxGuests, rating | number (giá theo VND) |
| | amenities | array<string> |
| | status | available / occupied / maintenance |
| | cleaningStatus | clean / dirty / cleaning |
| users / Firebase Auth UID | name, email, phone | string |
| | role | customer / admin (chỉ để hiển thị) |
| bookings / ID tự sinh | roomId, roomName, userId, userName, paymentMethod | string |
| | contactPhone, discountCode | string hoặc null |
| | checkIn, checkOut, createdAt | Firestore Timestamp |
| | guests, subtotal, discountPercent, total | number |
| | status | pending / confirmed / completed / cancelled |
| discounts / WELCOME10 | code | string |
| | percent | number, 0–100 |
| | expiry | Firestore Timestamp |
| | active | boolean |

Firestore tạo collection khi ghi document đầu tiên. Seed nạp 12 phòng và 3 mã giảm giá; users/bookings được tạo khi có tài khoản và đơn thật. Không nạp mật khẩu, tài khoản hay đơn demo vào cloud. Các trạng thái phòng và mã giảm giá seed là dữ liệu demo: kiểm tra lại trước khi dùng thật.

## Tạo project lần đầu

1. Mở https://console.firebase.google.com/ bằng tài khoản Google của bạn, chọn tạo project, ví dụ tên `Cozy Homestay`. Ghi lại **Project ID** thực tế.
2. Vào **Build → Firestore Database → Create database**, chọn Standard edition, database `(default)`, vị trí phù hợp và chế độ Production.
3. Vào **Authentication → Get started → Sign-in method**, bật **Email/Password**.
4. Trong **Project settings → General**, thêm ứng dụng Web và giữ cấu hình Firebase để kết nối Flutter sau.

## Đưa quy tắc và dữ liệu lên Firebase

Cần Node.js và quyền quản trị project. Chạy ở thư mục `homestay_app` có `pubspec.yaml`:

```powershell
npx firebase-tools login
npx firebase-tools deploy --only firestore --project lost-31a48
cd firebase
npm install
npm run check
```

Thay `lost-31a48` bằng ID thật. Để chạy Admin SDK, dùng Application Default Credentials của tài khoản có quyền Firestore (nếu đã cài Google Cloud CLI):

```powershell
gcloud auth application-default login
npm run seed -- lost-31a48
```

Script tạo toàn bộ danh mục trong một batch. Nếu có ID đã tồn tại, batch thất bại và không ghi đè dữ liệu. `seed.json` là đầu vào cho script này, không phải định dạng import trực tiếp của Firebase Console. Ngày hết hạn đã được chốt lúc xuất; để tạo lại, chạy `dart run tool/export_firebase_seed.dart` tại thư mục ứng dụng trước khi seed.

## Kết nối website (bước tiếp theo)

App hiện chưa có Firebase SDK. Khi có project, cần thêm `firebase_core`, `firebase_auth`, `cloud_firestore`, chạy FlutterFire configure và khởi tạo Firebase trước `runApp`; chuyển AppProvider từ dữ liệu mock sang Auth/Firestore và sửa các thao tác giao diện sang bất đồng bộ. Không dùng đăng nhập demo làm xác thực Firebase.

Rules cho phép khách đọc phòng, đọc hồ sơ/đơn của chính mình và tra mã giảm giá bằng document ID. Truy vấn lịch sử phải có `where('userId', isEqualTo: uid)`.

Quyền quản trị dựa trên custom claim `admin: true` do môi trường Admin SDK tin cậy cấp, không dựa vào trường role mà người dùng gửi. Backend tin cậy cần xác thực người đặt, tính tổng tiền từ giá và mã giảm giá trong database, kiểm tra ngày/số khách, giữ chỗ theo từng đêm trong transaction để tránh trùng lịch. Khách chưa được phép ghi đơn trực tiếp theo rules hiện tại; không mở write công khai để bỏ qua phần backend. Thanh toán hiện vẫn là mô phỏng.

Tài liệu chính thức: https://firebase.google.com/docs/firestore/quickstart và https://firebase.google.com/docs/admin/setup.


