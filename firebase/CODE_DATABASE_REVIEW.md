# Đối chiếu code và Firestore — 10/09/2026

Phạm vi: models, AppProvider, các màn hình khách/admin, form liên hệ, rules/indexes và dữ liệu cloud project lost-31a48.

| Chức năng hiện có | Nơi lưu phù hợp | Kết quả |
|---|---|---|
| Danh mục, giá, tiện nghi, điểm đánh giá phòng | rooms | Đã có 12 phòng |
| Trạng thái phòng và dọn phòng | rooms.status / cleaningStatus | Không cần bảng dọn phòng riêng khi chưa có lịch sử/phân công |
| Hồ sơ khách và vai trò hiển thị | users | Đã có hồ sơ mẫu; tài khoản thật phải dùng Auth UID |
| Đặt phòng, lịch, phương thức thanh toán, tổng tiền | bookings | Đã có lịch mẫu; chưa có giao dịch cổng thanh toán |
| Mã giảm giá | discounts | Đã có 3 mã |
| Form liên hệ ở home_screen.dart | contact_requests | Bổ sung bảng, mẫu và rules riêng tư |
| Thống kê doanh thu/dashboard | Tổng hợp bookings | Chưa cần nhân bản dữ liệu sang bảng thống kê |
| Dịch vụ, giới thiệu, gallery, lời nhận xét trang chủ | Nội dung tĩnh trong widget | Không có chức năng quản trị/gửi đánh giá nên chưa cần bảng riêng |

## Schema contact_requests

- ID: tự sinh cho yêu cầu thật; example-contact chỉ để xem cấu trúc.
- name, email, phone, message: string.
- status: new / in_progress / closed.
- createdAt: Timestamp do backend đặt.
- isDemo: boolean, true với bản mẫu; mẫu có trạng thái closed.
- Chỉ admin được đọc/ghi qua client. Form khách chưa được nối Firebase; backend tiếp nhận cần kiểm tra trường, giới hạn độ dài/tần suất và chống spam. Không mở quyền đọc công khai thông tin liên hệ.

## Các vấn đề cần giải quyết khi chuyển website sang vận hành thật

1. AppProvider khởi tạo cả 4 danh sách từ MockData, pubspec chưa có Firebase SDK. Thêm bảng trên cloud chưa làm website đồng bộ hoặc nhanh hơn.
2. Đăng nhập so sánh mật khẩu văn bản trong UserModel. Chuyển sang Firebase Authentication; tuyệt đối không chuyển trường password từ mock lên Firestore.
3. Form liên hệ không có controller hoặc lệnh lưu, nút gửi chỉ hiển thị SnackBar. Chỉ thông báo thành công sau khi backend xác nhận đã lưu.
4. createBooking tính giá ở client, chưa kiểm tra trùng lịch, và đánh dấu occupied ngay cả khi đặt ngày tương lai. Backend phải xác thực giá, ngày, sức chứa, mã giảm giá và giữ chỗ trong transaction. Chỉ tạo dữ liệu khóa từng đêm khi triển khai transaction thật.
5. bookingsOnDate tính cả ngày checkout; nếu biểu diễn đêm lưu trú nên dùng checkIn <= ngày < checkOut. Hủy một đơn cũng có thể đặt trạng thái phòng available dù còn đơn khác; không suy ra tồn phòng chỉ từ một lần hủy.
6. Dashboard cộng các đơn completed để gọi là doanh thu, không có xác nhận thanh toán thật. Chỉ cần payments khi tích hợp cổng thanh toán/webhook, không tạo giao dịch giả lúc này.

Tối ưu khi kết nối: truy vấn bookings theo userId và phân trang; admin tải lịch theo khoảng ngày/tháng; dùng các indexes hiện có cho userId/createdAt và roomId/checkIn. Không tải toàn bộ khách và đơn vào trình duyệt. Không thêm index không có truy vấn sử dụng. Đây là rà soát dữ liệu và cấu trúc, chưa phải sửa toàn bộ backend hay kiểm thử hiệu năng website.
