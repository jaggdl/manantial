class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :track_ahoy_visit
end
