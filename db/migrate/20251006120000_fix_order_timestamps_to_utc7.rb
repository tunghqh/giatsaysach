class FixOrderTimestampsToUtc7 < ActiveRecord::Migration[7.1]
  def up
    say_with_time "Update all order timestamps to UTC+7" do
      Order.find_each do |order|
        # Cộng thêm 7 tiếng cho các trường datetime nếu chưa đúng UTC+7
        %i[created_at updated_at received_at started_washing_at completed_washing_at paid_at].each do |field|
          value = order.send(field)
          if value.present? && value.hour < 7 # Giả định record cũ đang ở UTC
            order.update_column(field, value + 7.hours)
          end
        end
      end
    end
  end

  def down
    say_with_time "Revert all order timestamps to UTC" do
      Order.find_each do |order|
        %i[created_at updated_at received_at started_washing_at completed_washing_at paid_at].each do |field|
          value = order.send(field)
          if value.present? && value.hour >= 7 # Chỉ revert nếu đã cộng 7 tiếng
            order.update_column(field, value - 7.hours)
          end
        end
      end
    end
  end
end
