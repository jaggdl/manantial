module Peers
  class ProfilesController < BaseController
    allow_unauthenticated_access
    skip_before_action :verify_authenticity_token

    # GET /peers/profile
    # Returns public profile info for this instance's owner.
    # Used by peer instances to render names and avatars.
    def show
      owner = Current.owner

      unless owner
        return render json: { error: "No owner configured" }, status: :not_found
      end

      render json: ProfileSerializer.new(owner, self)
    end
  end
end
