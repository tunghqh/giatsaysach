class ShiftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shift, only: [:edit, :update]

  # Staff screen: list recent shifts and start new one
  def index
    @staff_names = ['Lâm', 'Vy', 'Liên', 'Trang']
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
      @staff_names = ['Lâm', 'Vy', 'Liên', 'Trang']
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
      redirect_to shifts_path(staff_name: @shift.staff_name), notice: 'Đã kết ca.'
    else
      render :edit
    end
  end

  private

  def set_shift
    @shift = Shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:user_id, :start_cash, :end_cash, :staff_name)
  end
end
