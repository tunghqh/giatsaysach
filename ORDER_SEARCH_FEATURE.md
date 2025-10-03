# Chức năng Tìm kiếm Đơn hàng

## Tổng quan
Hệ thống tìm kiếm đơn hàng cho phép người dùng nhanh chóng tìm thấy đơn hàng dựa trên nhiều tiêu chí khác nhau.

## Tính năng Tìm kiếm

### 🔍 **Tìm kiếm theo Text**
- **Tìm theo số điện thoại**: Nhập full hoặc một phần số điện thoại
- **Tìm theo tên khách hàng**: Nhập full hoặc một phần tên
- **Tìm kiếm thông minh**: Tự động tìm cả SĐT và tên trong cùng 1 query

### 📊 **Bộ lọc nâng cao**
- **Lọc theo trạng thái**: Nhận đơn, Đang giặt, Hoàn thành, Đã thanh toán
- **Lọc theo ngày tạo**: Chọn ngày cụ thể để xem đơn hàng
- **Kết hợp filters**: Có thể tìm kiếm + lọc trạng thái + lọc ngày cùng lúc

### ✨ **UX Features**

#### **Giao diện thân thiện:**
- Form tìm kiếm compact trên 1 dòng
- Icons rõ ràng cho mỗi field
- Button clear để xóa nhanh
- Responsive design cho mobile

#### **Feedback realtime:**
- **Highlight search terms**: Từ khóa tìm kiếm được đánh dấu vàng
- **Kết quả thống kê**: Hiển thị số lượng đơn tìm thấy
- **Empty state thông minh**: Gợi ý khác nhau cho search vs no data
- **Loading states**: Visual feedback khi đang xử lý

#### **Shortcuts & UX:**
- **Auto focus**: Tự động focus vào search input nếu có search term
- **ESC to clear**: Nhấn ESC để xóa nhanh search
- **Persistent state**: Giữ nguyên search terms sau khi search

## Cách sử dụng

### 1. **Tìm kiếm cơ bản**
```
Tìm theo SĐT: "0123456789" hoặc "0123"
Tìm theo tên: "Nguyễn Văn A" hoặc "Nguyễn"
```

### 2. **Kết hợp với filters**
```
Search: "Nguyễn" + Status: "Hoàn thành"
Search: "0123" + Date: "03/10/2025"
Status: "Đang giặt" + Date: "Hôm nay"
```

### 3. **Workflows thực tế**

#### **Tìm đơn của khách hàng cụ thể:**
1. Nhập tên hoặc SĐT vào search box
2. Nhấn Enter hoặc click "Tìm kiếm"
3. Xem kết quả với terms được highlight

#### **Kiểm tra đơn hàng theo ngày:**
1. Chọn ngày trong date picker
2. Click "Tìm kiếm"
3. Xem tất cả đơn trong ngày đó

#### **Tìm đơn theo trạng thái + khách hàng:**
1. Nhập tên/SĐT trong search
2. Chọn trạng thái từ dropdown
3. Click "Tìm kiếm"

## Technical Implementation

### Backend (Rails)
```ruby
# OrdersController#index
@orders = Order.includes(:customer).recent
@orders = @orders.by_status(params[:status]) if params[:status].present?
@orders = @orders.search_by_customer(params[:search].strip) if params[:search].present?

# Order Model Scopes
scope :search_by_customer, ->(term) {
  where("customer_name LIKE ? OR customer_phone LIKE ?", "%#{term}%", "%#{term}%")
}
scope :created_on_date, ->(date) {
  where(created_at: date.beginning_of_day..date.end_of_day)
}
```

### Frontend (JavaScript)
```javascript
// Search term highlighting
function highlightSearchTerms(term) {
  const regex = new RegExp(`(${term})`, 'gi');
  const cells = document.querySelectorAll('td:nth-child(2), td:nth-child(3)');
  
  cells.forEach(cell => {
    if (cell.textContent.toLowerCase().includes(term.toLowerCase())) {
      cell.innerHTML = cell.innerHTML.replace(regex, '<mark class="bg-warning">$1</mark>');
    }
  });
}
```

### CSS Styling
```css
/* Search highlighting */
mark.bg-warning {
  background-color: #fff3cd !important;
  color: #856404;
  padding: 0.125rem 0.25rem;
  border-radius: 0.25rem;
  font-weight: 600;
}
```

## Performance Considerations

### Database Optimization
- **Indexes**: Đã có index trên customer_name và customer_phone
- **LIKE queries**: Optimized cho MySQL với proper collation
- **Includes**: Eager loading để tránh N+1 queries

### Frontend Performance
- **Debouncing**: Có thể thêm debounce cho auto-search
- **Pagination**: Có thể thêm khi data lớn
- **Caching**: Browser cache search results

## Examples để test

### Sample Searches:
```
"Tùng" → Tìm customers có tên chứa "Tùng"
"0123" → Tìm customers có SĐT chứa "0123"  
"Test Customer" → Exact name match
"09" → Tìm tất cả SĐT bắt đầu bằng 09
```

### Combined Filters:
```
Search: "Nguyễn" + Status: "Hoàn thành"
Date: "Hôm nay" + Status: "Đang giặt"
Search: "0999" + Date: "03/10/2025"
```

## Future Enhancements

### Có thể thêm:
- **Full-text search**: Search trong notes/descriptions
- **Advanced filters**: Lọc theo giá trị đơn hàng, loại giặt
- **Saved searches**: Lưu các search patterns thường dùng
- **Export results**: Export kết quả tìm kiếm ra Excel
- **Auto-suggestions**: Gợi ý customer names khi gõ
- **Search history**: Lịch sử tìm kiếm gần đây

Chức năng tìm kiếm giúp nhân viên nhanh chóng tìm thấy đơn hàng cần thiết, cải thiện đáng kể hiệu quả công việc! 🔍✨