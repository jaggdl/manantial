module Peers
  class ConnectionsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      @connection = Connection.new(hostname: connection_params[:hostname])

      if @connection.persisted?
        render json: { access_key: @connection.access_key }, status: :created
      else
        render json: { error: @connection.errors.full_messages.first }, status: :unprocessable_entity
      end
    end

    def confirm
      their_access_key = connection_params[:access_key]
      hostname = connection_params[:hostname]

      if their_access_key.blank? || hostname.blank?
        return render json: { error: "Access key and hostname are required" }, status: :unprocessable_entity
      end

      verified = verify_peer(hostname)

      unless verified
        return render json: { error: "Verification failed. Could not reach the peer instance." }, status: :unauthorized
      end

      @connection = Connection.find_or_initialize_by(hostname: hostname)

      if @connection.persisted? && @connection.active?
        render json: { error: "Connection already active" }, status: :conflict
      elsif @connection.persisted? && @connection.pending?
        @connection.accept!(their_access_key)
        render json: { message: "Connection accepted" }, status: :ok
      else
        @connection = Connection.create!(hostname: hostname, peer_access_key: their_access_key, access_key: SecureRandom.hex(32))
        render json: { message: "Connection created and accepted", access_key: @connection.access_key }, status: :created
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def destroy
      @connection = Connection.find_by(hostname: params[:hostname])

      unless @connection
        return render json: { error: "Connection not found" }, status: :not_found
      end

      @connection.reject!
      render json: { message: "Connection revoked" }, status: :ok
    end

    def verify
      render json: { verified: true, hostname: request.host }
    end

    private

    def connection_params
      params.require(:peer).permit(:hostname, :access_key)
    end

    def verify_peer(hostname)
      uri = URI("https://#{hostname}/peers/connection/verify")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 3
      http.read_timeout = 5

      response = http.get(uri.path)
      response.code == "200"
    rescue StandardError => e
      false
    end
  end
end
