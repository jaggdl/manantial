class UsersController < ApplicationController
  before_action :redirect_if_user_exists, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  private

  def redirect_if_user_exists
    if User.exists?
      redirect_to new_user_session_path, alert: 'An account already exists. Please log in.'
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
