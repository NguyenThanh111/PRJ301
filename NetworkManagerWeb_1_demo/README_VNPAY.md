# Tích hợp thanh toán VNPAY

## Thành phần đã triển khai

- Tạo URL thanh toán VNPAY API `2.1.0`, ký `HmacSHA512`, thời hạn giao dịch 15 phút.
- Số tiền/gói dịch vụ được lấy từ catalog ở server, không tin dữ liệu giá từ trình duyệt.
- Return URL `/vnpay/return` và IPN `/vnpay/ipn` cùng kiểm tra chữ ký, `vnp_TmnCode`, mã đơn và số tiền.
- Callback xử lý idempotent: một đơn chỉ được xác nhận/kích hoạt dịch vụ một lần dù Return/IPN gọi lặp hoặc đồng thời.
- Giao dịch thành công kích hoạt hoặc gia hạn `UserSubscription` trong cùng database transaction.
- Lưu lịch sử giao dịch, mã VNPAY, ngân hàng, loại thẻ, mã phản hồi và thời gian thanh toán.

## 1. Cập nhật database

Với database đã tồn tại, chạy bằng SQL Server Management Studio:

```sql
web/lib/VnpayMigration.sql
```

Nếu tạo database mới bằng toàn bộ `web/lib/Network2.sql`, các bảng VNPAY đã có sẵn ở cuối file.

## 2. Thêm khóa VNPAY

Sao chép:

```text
web/WEB-INF/vnpay.properties.example
```

thành:

```text
web/WEB-INF/vnpay.properties
```

Sau đó điền `vnpay.tmnCode`, `vnpay.hashSecret`, Return URL và IPN URL công khai. File thật đã được `.gitignore` để tránh lộ khóa.

Có thể cấu hình an toàn hơn bằng biến môi trường (được ưu tiên cao nhất):

- `VNPAY_TMN_CODE`
- `VNPAY_HASH_SECRET`
- `VNPAY_PAY_URL`
- `VNPAY_RETURN_URL`
- `VNPAY_IPN_URL`

Sandbox Pay URL mặc định: `https://sandbox.vnpayment.vn/paymentv2/vpcpay.html`.

## 3. Đăng ký URL tại VNPAY

- Return URL: `https://<domain>/<context>/vnpay/return`
- IPN URL: `https://<domain>/<context>/vnpay/ipn`

IPN phải là URL HTTPS công khai mà máy chủ VNPAY truy cập được; `localhost` không nhận được IPN. Không bảo vệ IPN bằng đăng nhập, CSRF hoặc redirect vì tính xác thực được bảo đảm bởi chữ ký HMAC.

## 4. Kiểm thử

1. Đăng nhập và mở `/payment/checkout`.
2. Chọn gói và kênh thanh toán.
3. Hoàn thành/hủy giao dịch trên sandbox VNPAY.
4. Kiểm tra trang kết quả và hai bảng `PaymentTransaction`, `UserSubscription`.
5. Gửi lại cùng callback để xác nhận hệ thống trả `RspCode=02` và không gia hạn lần hai.

Khi chuyển production, thay Pay URL và bộ khóa production, đăng ký lại chính xác Return/IPN URL, dùng HTTPS hợp lệ, và không dùng lại khóa sandbox.
