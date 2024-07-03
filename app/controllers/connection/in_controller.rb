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

      render json: { message: 'Connection was successfully created.'}, status: :created
    end

    def destroy
      @in = In.find(params[:id])
      @in.destroy

      redirect_to connection_in_index_path, notice: 'Connection was successfully deleted.'
    end

    def approve
      @in = In.find(params[:id])
      @in.update(approved: true) # Assuming there's an approved boolean column in the connections table

      redirect_to connection_in_index_path, notice: 'Connection was successfully approved.'
    end

    private

    def in_params
      params.require(:in).permit(:domain, :nonce, :message)
    end
  end
end
