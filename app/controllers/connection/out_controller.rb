module Connection
  class OutController < ApplicationController
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
      origin_url = URI(ENV['DOMAIN'])

      begin
        connection_service = Connection::HttpService.new(@out.domain)
        connection_request_response = connection_service.post(
          connection_in_index_path,
          body: {
            domain: origin_url.hostname,
            message: message,
            nonce: @out.nonce
          },
        )

        unless @out.save
          flash.now[:alert] = @out.errors.full_messages.join(", ")
          render :new and return
        end

        redirect_to connection_out_index_path, notice: 'Out was successfully created.'
      rescue Connection::HttpService::HttpServiceError => e
        flash.now[:alert] = "Error: #{e.message}"
        render :new
      end
    end

    def destroy
      @out = Out.find(params[:id])
      @out.destroy

      redirect_to connection_out_index_path, notice: 'Connection was successfully deleted.'
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
