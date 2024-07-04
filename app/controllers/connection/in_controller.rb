module Connection
  class InController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :set_in, only: [:destroy, :approve]

    def index
      @connections_in = In.all
    end

    def create
      @in = In.create(in_params)

      render json: { message: 'Connection was successfully created.' }, status: :created

    rescue ActiveRecord::RecordNotUnique => e
      render json: { message: 'Domain already exists.' }, status: :unprocessable_entity
    end

    def destroy
      @in.destroy
      redirect_to connections_url, notice: 'Connection was successfully deleted.'
    end

    def approve
      token = generate_token
      connection_service = Connection::Service.new(@in.domain)

      begin
        response = connection_service.set_connection(
          token:,
          nonce: @in.nonce,
        )

        connection_set = Connection::Set.create(
          token:,
          domain: @in.domain,
        )

        redirect_to connections_url, notice: 'Connection was successfully approved.'
      rescue Connection::Service::Error => e
        redirect_to connections_url, alert: "Error: #{e.message}"
      rescue => e
        redirect_to connections_url, alert: "#{e.message}"
        raise e
      end
    end

    private

    def in_params
      params_with_domain = params.require(:in).permit(:nonce, :message).merge(domain: request.headers['X-Origin-Domain'])
      params_with_domain
    end

    def set_in
      @in = In.find(params[:id])
    end

    def generate_token
      SecureRandom.hex(16)
    end
  end
end
