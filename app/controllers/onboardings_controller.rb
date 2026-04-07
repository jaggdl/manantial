class OnboardingsController < ApplicationController
  allow_unauthenticated_access

  before_action :require_no_users

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome! You've successfully set up your account."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email_address, :password, :password_confirmation)
  end

  def require_no_users
    return unless User.exists?

    redirect_to root_path, notice: "An account already exists."
  end
end
