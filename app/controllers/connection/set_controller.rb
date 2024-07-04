module Connection
  class SetController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      @out = Out.find_by(nonce: set_params[:nonce])

      unless @out.present?
        render json: { message: 'Invalid nonce' }, status: :unauthorized
      end

      @set = Set.create(
        domain: @out.domain,
        token: set_params[:token],
      )

      @out.destroy

      render json: { message: 'Connection was successfully created.' }, status: :created
    rescue ActiveRecord::RecordNotUnique => e
      render json: { message: 'Domain already exists.' }, status: :unprocessable_entity
    end

    def destroy
      @set = Set.find(params[:id])
      @set.destroy

      redirect_to connections_url, notice: 'Connection was successfully deleted.'
    end

    private

    def set_params
      params.permit(:nonce, :token)
    end
  end
end
