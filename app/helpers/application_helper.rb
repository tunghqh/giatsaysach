module ApplicationHelper
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
end
