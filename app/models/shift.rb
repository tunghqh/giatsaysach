class Shift < ApplicationRecord
  belongs_to :user
  validates :start_time, presence: true
  validates :start_cash, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :staff_name, presence: true

  scope :for_staff, ->(name) { where(staff_name: name) }

  # Compute total of orders that were paid between start_time and end_time
  def compute_total_paid!
    return 0 unless end_time.present?
    # final_total_amount is a Ruby method, not a DB column — sum DB columns instead
    total = Order.where(payment_status: 'payment_completed', payment_method: 'cash')
                 .where(paid_at: start_time..end_time)
                 .sum("COALESCE(total_amount,0) + COALESCE(shipping_fee,0) + COALESCE(extra_fee,0)")
    # Convert to integer (shifts.total_paid is integer); keep integer VND
    update(total_paid: total.to_i)
    total
  end
end
