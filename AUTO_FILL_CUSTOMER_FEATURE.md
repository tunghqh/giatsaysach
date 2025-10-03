# Tính năng Tự động điền thông tin Khách hàng

## Mô tả
Khi tạo đơn hàng mới, hệ thống sẽ tự động tìm kiếm và điền thông tin khách hàng dựa trên số điện thoại đã nhập.

## Cách hoạt động

### 1. Nhập số điện thoại
- Khi nhập số điện thoại (tối thiểu 10 số), hệ thống sẽ tự động tìm kiếm
- Hiển thị loading indicator trong khi tìm kiếm
- Kết quả tìm kiếm được debounce 500ms để tối ưu performance

### 2. Khách hàng đã tồn tại
- Tự động điền tên khách hàng
- Field tên sẽ được làm sáng (background màu xám) và read-only
- Hiển thị thông báo thành công "Đã tìm thấy khách hàng: [Tên]"
- Nhấp vào field tên để chỉnh sửa nếu cần

### 3. Khách hàng mới
- Field tên vẫn có thể chỉnh sửa bình thường
- Hiển thị thông báo "Khách hàng mới - vui lòng nhập tên"
- Tự động focus vào field tên để người dùng nhập

### 4. Lưu đơn hàng
- Hệ thống sử dụng `find_or_create_by` để tìm hoặc tạo customer
- Nếu customer đã tồn tại, cập nhật tên nếu có thay đổi
- Không tạo duplicate customer với cùng số điện thoại

## Lợi ích

### Cho người dùng:
- ✅ Tiết kiệm thời gian nhập liệu
- ✅ Giảm lỗi chính tả tên khách hàng
- ✅ Trải nghiệm mượt mà với loading indicator
- ✅ Có thể chỉnh sửa tên nếu cần

### Cho hệ thống:
- ✅ Không tạo duplicate customers
- ✅ Dữ liệu sạch và nhất quán
- ✅ Tối ưu performance với debouncing
- ✅ Xử lý lỗi gracefully

## Technical Implementation

### Frontend (JavaScript):
- Event listener trên field số điện thoại
- AJAX call tới `/search_customer` endpoint
- Debouncing để tránh spam requests
- UI feedback với loading indicators
- Xử lý edit mode cho field tên

### Backend (Rails):
- `search_customer` action trả về JSON
- `find_or_create_by` logic trong create action
- Cập nhật tên customer nếu có thay đổi
- Validation và error handling

### Database:
- Unique index trên phone field
- Quan hệ one-to-many Customer → Orders
- Automatic timestamp tracking

## Cách sử dụng

1. Vào trang tạo đơn hàng mới
2. Nhập số điện thoại (10+ số)
3. Đợi hệ thống tự động tìm kiếm
4. Nếu tìm thấy: tên sẽ được điền tự động
5. Nếu cần sửa tên: nhấp vào field tên → confirm → chỉnh sửa
6. Điền thông tin đơn hàng còn lại
7. Tạo đơn → hệ thống tự động link với customer phù hợp

Tính năng này giúp tối ưu workflow tạo đơn hàng và đảm bảo dữ liệu khách hàng luôn chính xác! 🎉