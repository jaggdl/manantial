class ConnectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @connections = Connection::Set.all
    @connections_in = Connection::In.all
    @connections_out = Connection::Out.all
  end
end
