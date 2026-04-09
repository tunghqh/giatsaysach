class ShiftsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :require_open_shift_for_staff
  before_action :set_shift, only: [:edit, :update, :save_diff_reason]

  # Staff screen: list recent shifts and start new one
  def index
    @staff_names = ['Lâm', 'Vy', 'Tâm', 'Trang', 'Diễm', 'Hân']
    @selected_staff = params[:staff_name] || @staff_names.first
    @shifts = Shift.for_staff(@selected_staff).order(created_at: :desc).limit(20)
    @shift = Shift.new(staff_name: @selected_staff)
    @open_shift = Shift.for_staff(@selected_staff).where(end_time: nil).order(created_at: :desc).first
  end

  def create
    @shift = Shift.new(shift_params)
    @shift.user = current_user
    @shift.start_time = Time.current
    # ensure staff_name is set from select
    @shift.staff_name = shift_params[:staff_name] if shift_params[:staff_name].present?

    if @shift.save
      redirect_to shifts_path(staff_name: @shift.staff_name), notice: 'Đã bắt đầu ca.'
    else
      @staff_names = ['Lâm', 'Vy', 'Tâm', 'Trang', 'Diễm', 'Hân']
      @selected_staff = params[:staff_name] || @staff_names.first
      @shifts = Shift.for_staff(@selected_staff).order(created_at: :desc).limit(20)
      @shift = Shift.new(staff_name: @selected_staff)
      render :index
    end
  end

  def edit
    # show end shift form
  end

  def update
    # set end time and end cash, then compute totals
    @shift.end_time = Time.current
    @shift.end_cash = shift_params[:end_cash]
    if @shift.save
      @shift.compute_total_paid!
      # expected cash = start_cash + total_paid
      expected = (@shift.start_cash || 0).to_i + (@shift.total_paid || 0).to_i
      end_cash = (@shift.end_cash || 0).to_i
      diff = end_cash - expected
      # if absolute difference > 10_000 VND, show modal in index view via flash
      if diff.abs > 10_000
        set_shift_diff_flash(@shift, diff, expected, end_cash)
      end
      redirect_to shifts_path(staff_name: @shift.staff_name), notice: 'Đã kết ca.'
    else
      render :edit
    end
  end

  def save_diff_reason
    unless current_user.admin? || @shift.user_id == current_user.id
      redirect_to shifts_path(staff_name: @shift.staff_name), alert: 'Bạn không có quyền cập nhật lý do cho ca này.'
      return
    end

    reason = params.dig(:shift, :diff_reason).to_s.strip

    if reason.blank?
      expected = (@shift.start_cash || 0).to_i + (@shift.total_paid || 0).to_i
      end_cash = (@shift.end_cash || 0).to_i
      diff = end_cash - expected
      set_shift_diff_flash(@shift, diff, expected, end_cash)
      redirect_to shifts_path(staff_name: @shift.staff_name), alert: 'Vui lòng nhập lý do chênh lệch trước khi gửi.'
      return
    end

    if @shift.update(diff_reason: reason)
      redirect_to shifts_path(staff_name: @shift.staff_name), notice: 'Đã lưu lý do chênh lệch.'
    else
      expected = (@shift.start_cash || 0).to_i + (@shift.total_paid || 0).to_i
      end_cash = (@shift.end_cash || 0).to_i
      diff = end_cash - expected
      set_shift_diff_flash(@shift, diff, expected, end_cash)
      redirect_to shifts_path(staff_name: @shift.staff_name), alert: @shift.errors.full_messages.to_sentence
    end
  end

  private

  def set_shift
    @shift = Shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:user_id, :start_cash, :end_cash, :staff_name)
  end

  def set_shift_diff_flash(shift, diff, expected, end_cash)
    flash[:show_shift_diff] = true
    flash[:shift_id] = shift.id
    flash[:shift_diff_amount] = diff
    flash[:shift_expected] = expected
    flash[:shift_end_cash] = end_cash
  end
end
