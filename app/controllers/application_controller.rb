class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :redirect_to_signup_if_no_users, only: :index

  def index
  end

  private

  def default_url_options
    { locale: I18n.locale == :en ? nil : I18n.locale }
  end

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def redirect_to_signup_if_no_users
    if User.count.zero?
      redirect_to new_user_registration_path unless request.path == new_user_registration_path
    end
  end
end
