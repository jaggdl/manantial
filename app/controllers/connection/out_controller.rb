module Connection
  class OutController < ApplicationController
    include HTTParty

    def index
      @connections_out = Out.all
    end

    def new
      @out = Out.new
    end

    def create
      @out = Out.find_or_initialize_by(domain: out_params[:domain])

      if @out.persisted?
        flash.now[:alert] = "Connect request has already been sent"
        render :new and return
      end

      @out.nonce = generate_nonce
      message = out_params[:message] || "Hello, let's connect"

      begin
        connection_service = Connection::HttpService.new(@out.domain)
        connection_request_response = connection_service.post(
          connection_in_index_path,
          body: {
            domain: ENV['domain'],
            message: message
          }.to_json
        )

        unless @out.save
          flash.now[:alert] = @out.errors.full_messages.join(", ")
          render :new and return
        end

        redirect_to @out, notice: 'Out was successfully created.'
      rescue Connection::HttpService::HttpServiceError => e
        flash.now[:alert] = "Error: #{e.message}"
        render :new
      end
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
