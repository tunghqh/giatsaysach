class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true,
                   format: { with: /\A[0-9+\-\s()]+\z/, message: "Số điện thoại không hợp lệ" }

  scope :search_by_phone, ->(phone) { where("phone LIKE ?", "%#{phone}%") }
end
