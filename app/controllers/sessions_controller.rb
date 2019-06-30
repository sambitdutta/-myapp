class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, except: %i[destroy]

  before_action :check_session, only: %i[new create]

  def new; end

  def create
    user = User.find_by(email: params[:login][:email].downcase)

    if user && user.authenticate(params[:login][:password])
      session[:user_id] = user.id.to_s
      redirect_to root_path, success: I18n.t('login.success')
    else
      flash.now.alert = I18n.t('login.failure')
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, success: I18n.t('logout.success')
  end

  private

  def check_session
    redirect_to root_path if current_user
  end
end
