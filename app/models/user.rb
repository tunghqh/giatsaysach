class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Removed :registerable to disable user registration
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  
  # Enum for user roles
  enum role: {
    user: 0,      # User thường - chỉ tạo đơn, update status
    admin: 1      # Admin - full quyền including edit, delete
  }
  
  # Scope để lọc theo role
  scope :admins, -> { where(role: :admin) }
  scope :regular_users, -> { where(role: :user) }
  
  def role_text
    case role
    when 'user' then 'Nhân viên'
    when 'admin' then 'Quản lý'
    end
  end
  
  # Helper methods for authorization
  def can_edit_orders?
    admin?
  end
  
  def can_delete_orders?
    admin?
  end
  
  def can_create_orders?
    true # Cả admin và user đều có thể tạo đơn
  end
  
  def can_update_order_status?
    true # Cả admin và user đều có thể update status
  end
end
