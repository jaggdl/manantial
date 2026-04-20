module Peers
  class ConnectionsController < ApplicationController
    allow_unauthenticated_access only: [ :index ]

    def index
      @connections = Connection.ordered
    end

    def create
      hostname = Connection.normalize_hostname(params[:hostname])

      if hostname.blank?
        return redirect_to connections_path, alert: "Hostname is required"
      end

      if Connection.exists?(hostname: hostname)
        return redirect_to connections_path, alert: "Connection already exists"
      end

      connection = Connection.initiate_outgoing!(hostname, request.host)

      if connection.persisted? && connection.pending?
        redirect_to connections_path, notice: "Connection request sent to #{connection.hostname}"
      else
        redirect_to connections_path, alert: "Could not connect: #{connection.error_message || 'Unknown error'}"
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to connections_path, alert: e.message
    end

    def accept
      hostname = Connection.normalize_hostname(params[:hostname])
      connection = Connection.find_by(hostname: hostname)

      unless connection
        return redirect_to connections_path, alert: "Connection not found"
      end

      unless connection.pending?
        return redirect_to connections_path, alert: "Connection is not pending"
      end

      connection = Connection.complete_acceptance!(hostname, request.host)

      if connection.active?
        redirect_to connections_path, notice: "Connected to #{connection.hostname}"
      else
        redirect_to connections_path, alert: "Could not complete connection: #{connection.error_message || 'Unknown error'}"
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      redirect_to connections_path, alert: e.message
    end

    def reject
      hostname = Connection.normalize_hostname(params[:hostname])
      connection = Connection.find_by(hostname: hostname)

      unless connection
        return redirect_to connections_path, alert: "Connection not found"
      end

      connection.reject!
      redirect_to connections_path, notice: "Connection request from #{hostname} rejected"
    end

    def destroy
      hostname = Connection.normalize_hostname(params[:hostname])
      connection = Connection.find_by(hostname: hostname)

      if connection
        connection.notify_revoke!(request.host)
        connection.destroy!
        redirect_to connections_path, notice: "Connection removed"
      else
        redirect_to connections_path, alert: "Connection not found"
      end
    end
  end
end
