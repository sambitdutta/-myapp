class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  before_action :check_session, only: %i[new create]
  before_action :verify_access, only: %i[show update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email.downcase!

    if @user.save
      session[:user_id] = @user.id.to_s
      @user.send_welcome_email
      flash[:success] = I18n.t('signup.success')
      redirect_to user_path(@user)
    else
      flash.now.alert = @user.errors.full_messages
      render :new
    end
  end

  def show; end

  def update
    @user.assign_attributes(user_params)
    if @user.save
      flash[:success] = I18n.t('user.update.success')
      redirect_to user_path(@user)
    else
      flash.now.alert = @user.errors.full_messages
      render :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def verify_access
    @user = User.find_friendly(params[:id])
    redirect_to root_path, alert: I18n.t('unauthorized') unless current_user.id == @user.id
  end

  def check_session
    redirect_to root_path if current_user
  end
end
