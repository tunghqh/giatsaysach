module QrHelper
  # Tạo payload VietQR cho VPBank
  # Tham khảo: https://vietqr.net/documentation.html
  # Chỉ cần account, bank_id, amount, addInfo
  def vietqr_payload_vpbank(account_number:, amount:, add_info: '')
    bank_id = '970432' # VPBank
    # Sử dụng link động của vietqr.net để lấy ảnh QR
    "https://img.vietqr.io/image/#{bank_id}-#{account_number}-compact.png?amount=#{amount}&addInfo=#{CGI.escape(add_info)}"
  end
end