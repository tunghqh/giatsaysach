class Order < ApplicationRecord
  belongs_to :customer

  # Enum for status
  enum status: {
    received: 0,      # Nhận đơn
    washing: 1,       # Đang giặt
    completed: 2,     # Đã giặt xong
    paid: 3           # Đã thanh toán
  }

  # Enum for payment status
  enum payment_status: {
    payment_pending: 0,     # Chưa thanh toán
    payment_completed: 1    # Đã thanh toán
  }

  # Enum for laundry types
  LAUNDRY_TYPES = [
    ['QUẦN ÁO', 'clothes'],
    ['CHĂN MỀN', 'blanket'],
    ['TOPPER', 'topper'],
    ['GIẶT ƯỚT/ SẤY KHÔ', 'wet_dry'],
    ['RÈM', 'curtain'],
    ['ÁO VEST/ DẠ', 'vest'],
    ['GIÀY', 'shoes'],
    ['TẨY QUẦN ÁO', 'bleach_clothes'],
    ['KHĂN SPA', 'spa_towel'],
    ['SƠ MI + QUẦN TÂY', 'shirt_pants'],
    ['KHÁC', 'other']
  ].freeze

  # Payment methods
  PAYMENT_METHODS = [
    ['Tiền mặt', 'cash'],
    ['Chuyển khoản', 'transfer']
  ].freeze

  validates :customer_name, presence: true
  validates :customer_phone, presence: true
  validates :laundry_type, presence: true, inclusion: { in: LAUNDRY_TYPES.map(&:last) }
  validates :weight, presence: true, if: :completed_or_paid?
  validates :total_amount, presence: true, if: :completed_or_paid?
  validates :payment_method, presence: true, if: :payment_status_paid?
  validates :shipping_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :extra_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Custom validation methods
  def completed_or_paid?
    completed? || paid?
  end

  def payment_status_paid?
    payment_status == 'payment_completed'
  end

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }
  scope :search_by_customer, ->(term) {
    where("customer_name LIKE ? OR customer_phone LIKE ?", "%#{term}%", "%#{term}%")
  }
  scope :created_on_date, ->(date) {
    where(created_at: date.beginning_of_day..date.end_of_day)
  }

  scope :paid_on_date, ->(date) {
    where(paid_at: date.beginning_of_day..date.end_of_day)
  }

  scope :paid_between_dates, -> (start_date, end_date){ where(paid_at: start_date..end_date) }

  def laundry_type_text
    LAUNDRY_TYPES.find { |type| type[1] == laundry_type }&.first || laundry_type
  end

  def status_text
    case status
    when 'received' then 'Nhận đơn'
    when 'washing' then 'Đang giặt'
    when 'completed' then 'Đã giặt xong'
    when 'paid' then 'Đã thanh toán'
    end
  end

  def payment_method_text
    PAYMENT_METHODS.find { |method| method[1] == payment_method }&.first || payment_method
  end

  # Calculate final total amount including fees
  def final_total_amount
    total_amount + shipping_fee + extra_fee
  end

  # Calculate subtotal (before fees)
  def subtotal
    total_amount
  end

  # Callbacks to set timestamps
  before_create :set_received_at
  before_update :set_status_timestamps

  private

  def set_received_at
    self.received_at = Time.current if received?
  end

  def set_status_timestamps
    if status_changed?
      case status
      when 'washing'
        self.started_washing_at = Time.current
      when 'completed'
        self.completed_washing_at = Time.current
      when 'paid'
        self.paid_at = Time.current
      end
    end
  end
end
