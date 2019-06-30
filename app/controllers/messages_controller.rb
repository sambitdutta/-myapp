class MessagesController < ApplicationController
  before_action :verify_access

  def index
    @messages = @user.messages
  end

  private

  def verify_access
    @user = User.find_friendly(params[:user_id])
    p @user
    p current_user
    redirect_to root_path, alert: I18n.t('unauthorized') unless current_user.id == @user.id
  end
end
