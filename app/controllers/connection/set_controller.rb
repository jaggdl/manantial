module Connection
  class SetController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      @out = Out.find_by(nonce: set_params[:nonce])

      @set = Set.create(
        domain: @out.domain,
        token: set_params[:token],
      )

      render json: { message: 'Connection was successfully created.' }, status: :created
    rescue ActiveRecord::RecordNotUnique => e
      render json: { message: 'Domain already exists.' }, status: :unprocessable_entity
    end

    private

    def set_params
      params.require(:set).permit(:nonce, :token)
    end
  end
end
