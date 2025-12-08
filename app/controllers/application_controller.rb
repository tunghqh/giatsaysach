require 'pagy'
class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!
  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  protected

  def after_sign_in_path_for(_resource)
    root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
