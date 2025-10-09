class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true,
                   format: { with: /\A\d+\z/, message: "Số điện thoại chỉ được chứa số" }

  scope :search_by_phone, ->(phone) { where("phone LIKE ?", "%#{phone}%") }
end
