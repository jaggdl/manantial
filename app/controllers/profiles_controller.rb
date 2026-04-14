class ProfilesController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  before_action :require_no_users, only: [ :new, :create ]
  skip_before_action :require_owner, only: [ :new, :create ]

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

  def edit
    @user = Current.owner
  end

  def update
    @user = Current.owner

    if @user.update(user_params)
      redirect_to root_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email_address, :avatar).tap do |whitelisted|
      if params[:user][:password].present?
        whitelisted[:password] = params[:user][:password]
        whitelisted[:password_confirmation] = params[:user][:password_confirmation]
      end
    end
  end

  def require_no_users
    return unless User.exists?

    redirect_to root_path, notice: "An account already exists."
  end
end
