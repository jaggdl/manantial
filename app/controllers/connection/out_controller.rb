module Connection
  class OutController < ApplicationController
    def index
      @connections_out = Out.all
    end

    def new
      @out = Out.new
    end

    def create
      @out = Out.new(out_params)
      @out.nonce = generate_nonce

      connection_service = Connection::Service.new(@out.domain)

      begin
        message = out_params[:message] || "Hello, let's connect"

        response = connection_service.request_connection(
          message: message,
          nonce: @out.nonce,
        )

        @out.save!

        redirect_to connections_url, notice: 'Out was successfully created.'
      rescue Connection::Service::Error => e
        redirect_to connections_url, alert: "Error: #{e.message}"
      rescue => e
        redirect_to connections_url, alert: "#{e.message}"
      end
    end

    def destroy
      @out = Out.find(params[:id])
      @out.destroy

      redirect_to connections_url, notice: 'Connection was successfully deleted.'
    end

    private

    def out_params
      params.require(:out).permit(:domain, :message)
    end

    def generate_nonce
      SecureRandom.hex(16)
    end
  end
end
