class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :error_handler

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to login_path, alert: I18n.t('unauthorized') if current_user.nil?
  end

  def error_handler(exception)
    redirect_to root_path, alert: exception.message
  end
end
