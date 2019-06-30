class PasswordResetsController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :check_session
  before_action :verify_user, only: %i[show update]
  before_action :verify_expiration, only: %i[show update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user.present?
      @user.create_reset_token
      @user.send_password_reset_email
      flash[:notice] = I18n.t('password_reset.email.sent')
      redirect_to login_path
    else
      flash.now.alert = I18n.t('password_reset.email.not_found')
      render :new
    end
  end

  def show
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = I18n.t('password_reset.success')
      redirect_to login_path
    else
      flash.now.alert = @user.errors.full_messages
      render :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def verify_user
    @user = User.find_by(email: params[:email])
    redirect_to login_path, alert: I18n.t('password_reset.token.invalid') unless @user && @user.authentic_reset_token?(params[:id])
  end

  def verify_expiration
    redirect_to login_path, alert: I18n.t('password_reset.token.expired') if @user.reset_token_expired?
  end

  def check_session
    redirect_to root_path if current_user
  end
end
