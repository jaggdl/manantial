module Peers
  class ConnectionsController < ApplicationController
    allow_unauthenticated_access only: [ :create, :confirm, :verify, :revoke ]
    skip_before_action :verify_authenticity_token, only: [ :create, :confirm, :verify, :revoke, :destroy ]

    def index
      @connections = Connection.ordered
    end

    def create
      respond_to do |format|
        format.json { handle_peer_create }
        format.html { handle_user_create }
      end
    end

    def confirm
      their_access_key = connection_params[:access_key]
      hostname = Connection.normalize_hostname(connection_params[:hostname])
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

    def destroy
      respond_to do |format|
        format.json do
          hostname = Connection.normalize_hostname(params[:hostname])
          @connection = Connection.find_by(hostname: hostname)

          unless @connection
            return render json: { error: "Connection not found" }, status: :not_found
          end

          @connection.destroy!
          render json: { message: "Connection revoked" }, status: :ok
        rescue ActiveRecord::RecordNotDestroyed => e
          render json: { error: e.message }, status: :unprocessable_entity
        end

        format.html do
          unless authenticated?
            return redirect_to new_session_path
          end

          hostname = Connection.normalize_hostname(params[:hostname])
          @connection = Connection.find_by(hostname: hostname)

          if @connection
            @connection.notify_revoke!(request.host)
            @connection.destroy!
            redirect_to peers_connections_path, notice: "Connection removed"
          else
            redirect_to peers_connections_path, alert: "Connection not found"
          end
        end
      end
    end

    def verify
      nonce = params[:nonce]

      if nonce.blank?
        return render json: { error: "Nonce is required" }, status: :unprocessable_entity
      end

      render json: { verified: true, hostname: request.host }
    end

    def revoke
      hostname = Connection.normalize_hostname(params[:hostname])
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

    def handle_peer_create
      hostname = Connection.normalize_hostname(connection_params[:hostname])

      if hostname.blank?
        return render json: { error: "Hostname is required" }, status: :unprocessable_entity
      end

      existing = Connection.find_by(hostname: hostname)
      if existing
        return render json: { error: "Connection already exists" }, status: :conflict
      end

      @connection = Connection.new(hostname: hostname)

      unless Connection.verify_peer(hostname, @connection.nonce)
        return render json: { error: "Verification failed. Could not reach the peer instance." }, status: :unauthorized
      end

      if @connection.save
        render json: { token: @connection.access_key, nonce: @connection.nonce }, status: :created
      else
        render json: { error: @connection.errors.full_messages.first }, status: :unprocessable_entity
      end
    end

    def handle_user_create
      unless authenticated?
        return redirect_to new_session_path
      end

      hostname = Connection.normalize_hostname(params[:hostname])

      if hostname.blank?
        return redirect_to peers_connections_path, alert: "Hostname is required"
      end

      if Connection.exists?(hostname: hostname)
        return redirect_to peers_connections_path, alert: "Connection already exists"
      end

      connection = Connection.initiate_outgoing!(hostname, request.host)

      if connection.active?
        redirect_to peers_connections_path, notice: "Connected to #{connection.hostname}"
      else
        redirect_to peers_connections_path, alert: "Could not connect: #{connection.error_message || 'Unknown error'}"
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to peers_connections_path, alert: e.message
    end

    def connection_params
      params.permit(:hostname, :access_key, :nonce)
    end
  end
end
