module Connection
  class InController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def index
      @connections_in = In.all
    end

    def create
      @in = In.new(in_params)

      unless @in.save
        render json: { message: @in.errors.full_messages.join(", ") }, status: :error
        return
      end

      render json: { message: 'Connection was successfully created.', data: @out }, status: :created
    end

    private

    def in_params
      params.require(:in).permit(:domain, :nonce, :message)
    end
  end
end
