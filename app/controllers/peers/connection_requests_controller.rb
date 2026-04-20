module Peers
  class ConnectionRequestsController < BaseController
    allow_unauthenticated_access
    skip_before_action :verify_authenticity_token

    # POST /peers/connection
    # Receives an incoming connection request from a peer.
    # Body: { hostname: "sender.com", access_key: "their-token-for-us" }
    # Returns: { nonce: "..." }
    def create
      hostname = normalized_hostname
      their_access_key = connection_params[:access_key]

      if hostname.blank? || their_access_key.blank?
        return render json: { error: "Hostname and access_key are required" }, status: :unprocessable_entity
      end

      existing = Connection.find_by(hostname: hostname)
      if existing
        return render json: { error: "Connection already exists" }, status: :conflict
      end

      @connection = Connection.new(hostname: hostname, peer_access_key: their_access_key)
      @connection.validate # trigger nonce generation

      unless Connection.verify_peer(hostname, @connection.nonce)
        return render json: { error: "Verification failed. Could not reach the peer instance." }, status: :unauthorized
      end

      if @connection.save
        render json: { nonce: @connection.nonce }, status: :created
      else
        render json: { error: @connection.errors.full_messages.first }, status: :unprocessable_entity
      end
    end

    # POST /peers/connection/confirm
    # Receives confirmation from a peer that accepted our request.
    # Body: { access_key: "their-token", nonce: "...", hostname: "their-domain" }
    def confirm
      their_access_key = connection_params[:access_key]
      hostname = normalized_hostname
      nonce = connection_params[:nonce]

      if their_access_key.blank? || hostname.blank? || nonce.blank?
        return render json: { error: "Access key, hostname, and nonce are required" }, status: :unprocessable_entity
      end

      @connection = Connection.find_by(hostname: hostname)

      unless @connection
        return render json: { error: "Connection not found" }, status: :not_found
      end

      unless @connection.pending?
        return render json: { error: "Connection is not pending" }, status: :conflict
      end

      unless @connection.nonce == nonce
        return render json: { error: "Invalid nonce" }, status: :unauthorized
      end

      @connection.accept!(their_access_key)
      render json: { message: "Connection accepted" }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    # DELETE /peers/connection/:hostname
    # Receives a disconnection request from a peer.
    def destroy
      hostname = normalized_hostname
      @connection = Connection.find_by(hostname: hostname)

      unless @connection
        return render json: { error: "Connection not found" }, status: :not_found
      end

      @connection.destroy!
      render json: { message: "Connection revoked" }, status: :ok
    rescue ActiveRecord::RecordNotDestroyed => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    # POST /peers/connection/verify
    # Proof-of-ownership: peer calls this to verify we control our domain.
    def verify
      nonce = params[:nonce]

      if nonce.blank?
        return render json: { error: "Nonce is required" }, status: :unprocessable_entity
      end

      render json: { verified: true, hostname: request.host }
    end

    # POST /peers/connection/revoke
    # Peer notifies us they have disconnected.
    def revoke
      hostname = normalized_hostname
      @connection = Connection.find_by(hostname: hostname)

      unless @connection
        return render json: { error: "Connection not found" }, status: :not_found
      end

      @connection.destroy!
      render json: { message: "Connection revoked" }, status: :ok
    rescue ActiveRecord::RecordNotDestroyed => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def connection_params
      params.permit(:hostname, :access_key, :nonce)
    end
  end
end
