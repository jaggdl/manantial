class ApplicationController < ActionController::Base
  before_action :redirect_to_signup_if_no_users, only: :index

  def index
  end

  private

  def redirect_to_signup_if_no_users
    if User.count.zero?
      redirect_to new_user_registration_path unless request.path == new_user_registration_path
    end
  end
end
