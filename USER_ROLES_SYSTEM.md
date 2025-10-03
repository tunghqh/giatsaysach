# Hệ thống Phân quyền User

## Tổng quan
Hệ thống giặt sấy sạch hiện có 2 loại user với các quyền khác nhau:

## Loại User

### 1. **Admin (Quản lý)** 
- **Role:** `admin` (role: 1)
- **Quyền hạn:**
  - ✅ Tạo đơn hàng mới
  - ✅ Xem danh sách và chi tiết đơn hàng
  - ✅ Cập nhật trạng thái đơn hàng (received → washing → completed → paid)
  - ✅ **Chỉnh sửa đơn hàng** (Edit)
  - ✅ **Xóa đơn hàng** (Delete)
  - ✅ Xem danh sách khách hàng
  - ✅ Xử lý thanh toán

### 2. **User (Nhân viên)** 
- **Role:** `user` (role: 0) - Default
- **Quyền hạn:**
  - ✅ Tạo đơn hàng mới
  - ✅ Xem danh sách và chi tiết đơn hàng
  - ✅ Cập nhật trạng thái đơn hàng (received → washing → completed → paid)
  - ✅ Xem danh sách khách hàng
  - ✅ Xử lý thanh toán
  - ❌ **KHÔNG thể chỉnh sửa đơn hàng**
  - ❌ **KHÔNG thể xóa đơn hàng**

## Giao diện đã cập nhật

### Navigation Bar
- **Chỉ 1 button "Tạo đơn hàng"** ở giữa navbar (màu xanh)
- **User info** hiển thị email + role badge
- **Dropdown menu** hiển thị vai trò chi tiết

### Danh sách đơn hàng
- **Admin:** Thấy nút Edit (✏️) và Delete (🗑️)
- **User:** Chỉ thấy nút View (👁️)

### Chi tiết đơn hàng  
- **Admin:** Có nút "Sửa" và "Xóa" trong header
- **User:** Chỉ có nút "Quay lại"

## Accounts để test

### Admin Account
- **Email:** `admin@giatsaysach.com`
- **Password:** `admin123`
- **Quyền:** Full access (edit, delete orders)

### User Account  
- **Email:** `user@giatsaysach.com`
- **Password:** `user123`
- **Quyền:** Limited access (no edit, no delete)

## Technical Implementation

### Database
```ruby
# Migration: AddRoleToUsers
add_column :users, :role, :integer, default: 0, null: false
add_index :users, :role
```

### User Model
```ruby
enum role: {
  user: 0,      # Nhân viên - quyền hạn chế
  admin: 1      # Quản lý - full quyền
}

# Helper methods
def can_edit_orders?    # admin only
def can_delete_orders?  # admin only  
def can_create_orders?  # both
def can_update_order_status? # both
```

### Controller Protection
```ruby
before_action :check_admin_permission, only: [:edit, :update, :destroy]

private
def check_admin_permission
  unless current_user.admin?
    redirect_to orders_path, alert: 'Không có quyền...'
  end
end
```

### View Authorization
```erb
<% if current_user.can_edit_orders? %>
  <!-- Edit button -->
<% end %>

<% if current_user.can_delete_orders? %>
  <!-- Delete button -->  
<% end %>
```

## Security Features

### 1. **Backend Protection**
- Controller-level authorization với `before_action`
- Redirect với thông báo lỗi rõ ràng

### 2. **Frontend Protection**
- Conditional rendering các button dựa trên quyền
- UI feedback về vai trò hiện tại

### 3. **User Experience**
- Role badge trong navigation
- Thông báo rõ ràng khi không có quyền
- Consistent UI behavior

## Workflow sử dụng

### Với Admin:
1. Login → Thấy role "Quản lý" 
2. Có thể edit/delete mọi đơn hàng
3. Full access toàn bộ chức năng

### Với User:
1. Login → Thấy role "Nhân viên"
2. Chỉ có thể xem và update status đơn hàng
3. Không thấy nút edit/delete
4. Cần admin để sửa/xóa đơn lỗi

Hệ thống đảm bảo security và phân quyền rõ ràng, phù hợp với quy trình quản lý giặt sấy thực tế! 🔒✨