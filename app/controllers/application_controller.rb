require 'pagy'
class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
  before_action :require_open_shift_for_staff
  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  protected

  # Chặn mọi action nếu là nhân viên mà chưa bắt đầu ca
  def require_open_shift_for_staff
    return unless user_signed_in?
    return if current_user.admin?
    if Shift.last.end_time.present?
      respond_to do |format|
        format.html do
          flash.now[:alert] = 'Bạn cần bắt đầu ca làm việc trước khi sử dụng hệ thống.'
          render template: 'shared/shift_required', status: :forbidden
        end
        format.json { render json: { error: 'Bạn cần bắt đầu ca làm việc.' }, status: :forbidden }
      end
    end
  end

  def after_sign_in_path_for(_resource)
    root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
