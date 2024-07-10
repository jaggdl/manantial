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

      service = ServiceHandler.new(@out)
      result = service.create(out_params[:message] || "Hello, let's connect")

      if result[:success]
        redirect_to connections_url, notice: result[:message]
      else
        redirect_to connections_url, alert: result[:message]
        raise result[:raise_error] if result[:raise_error]
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
