class Api::V1::ConnectionController < ActionController::Base
  def show
    profile = Profile.last

    unless profile.present?
      render json: { message: 'Profile not found' }, status: :not_found
    end

    profile_picture = nil

    if profile.profile_picture.present?
      profile_picture = File.join(ENV['DOMAIN'], profile.profile_picture.sm.avif.url)
    end

    render json: {
      name: I18n.t('short_name'),
      profile_picture:,
    }
  end
end
