module Api
  class ProfileController < BaseController
    def show
      user = Current.user
      render json: {
        id: user.id,
        name: user.name,
        email_address: user.email_address,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    end

    def update
      user = Current.user

      if user.update(profile_params)
        render json: {
          id: user.id,
          name: user.name,
          email_address: user.email_address,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.permit(:name, :email_address, :password, :password_confirmation)
    end
  end
end
