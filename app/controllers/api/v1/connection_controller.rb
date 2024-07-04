class Api::V1::ConnectionController < ActionController::Base
  def show
    image_path = ActionController::Base.helpers.asset_path('headshot.jpg')

    render json: {
      name: I18n.t('short_name'),
      profile_picture: File.join(ENV['DOMAIN'], image_path)
    }
  end
end
