module ApplicationHelper
  include Pagy::Frontend
  def number_to_words(number)
    return "không" if number.to_i == 0

    # Simplified version for basic number conversion
    number = number.to_i

    case
    when number < 1000
      convert_hundreds(number)
    when number < 1000000
      thousands = number / 1000
      remainder = number % 1000
      result = convert_hundreds(thousands) + " nghìn"
      result += " " + convert_hundreds(remainder) if remainder > 0
      result
    when number < 1000000000
      millions = number / 1000000
      remainder = number % 1000000
      result = convert_hundreds(millions) + " triệu"
      if remainder >= 1000
        thousands = remainder / 1000
        result += " " + convert_hundreds(thousands) + " nghìn"
        remainder = remainder % 1000
      end
      result += " " + convert_hundreds(remainder) if remainder > 0
      result
    else
      "rất lớn"
    end
  end

  def unit_price_special(laundry_type, weight, total_amount)
    if (laundry_type == 'clothes' && weight <= 2.3)
      '(< 2.3kg/30.000đ)'
    elsif laundry_type == 'blanket' && weight <= 1.5
      '(< 1.5kg/30.000đ)'
    elsif laundry_type == 'wet_dry' && weight <= 4
      '(< 4kg/30.000đ)'
    else
      unit_price(laundry_type, weight, total_amount)
    end
  end

  def total_amount(orders)
    orders.sum(:total_amount) + orders.sum(:extra_fee) + orders.sum(:shipping_fee)
  end

  private

  def convert_hundreds(num)
    return "" if num == 0

    ones = ["", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"]
    teens = ["mười", "mười một", "mười hai", "mười ba", "mười bốn", "mười lăm", "mười sáu", "mười bảy", "mười tám", "mười chín"]
    tens = ["", "", "hai mười", "ba mười", "bốn mười", "năm mười", "sáu mười", "bảy mười", "tám mười", "chín mười"]

    result = ""

    if num >= 100
      result += ones[num / 100] + " trăm"
      num %= 100
    end

    if num >= 20
      result += " " + tens[num / 10]
      num %= 10
      result += " " + ones[num] if num > 0
    elsif num >= 10
      result += " " + teens[num - 10]
    elsif num > 0
      result += " " + ones[num]
    end

    result.strip
  end

  def unit_price(laundry_type, weight, total_amount)
    case laundry_type
    when 'clothes'
      '13.000đ'
    when 'blanket', 'curtain'
      '20.000đ'
    when 'topper'
      '30.000đ'
    when 'wet_dry'
      '8.000đ'
    when 'spa_towel'
      '11.000đ'
    when 'vest'
      '60.000đ'
    when 'shoes', 'bleach_clothes'
      '50.000đ'
    when 'shirt_pants'
      '25.000đ'
    else
      number_to_currency((total_amount / weight).round, unit: "đ", delimiter: ".", precision: 0, format: "%n%u")
    end
  end
end
