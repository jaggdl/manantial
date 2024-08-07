class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :redirect_to_signup_if_no_users, only: :index
  before_action :redirect_to_new_profile_if_no_profiles, only: :index
  skip_before_action :track_ahoy_visit, if: :user_signed_in?

  def index
    @posts = Post.public_posts.order(created_at: :desc).select(&:translated?).take(2)
    @connections_count = Connection::Set.count
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

  def redirect_to_new_profile_if_no_profiles
    unless Profile.exists?
      redirect_to new_profile_path unless request.path == new_profile_path
    end
  end
end
