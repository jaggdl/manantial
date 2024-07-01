class ConnectionsController < AuthenticatedController
  skip_before_action :verify_authenticity_token # Skip CSRF protection for API endpoint
  skip_before_action :authenticate_user!, only: ['receive']


  def create
    domain = params[:domain]

    @connection = Connection.new(domain: domain)

    if @connection.save
      render json: { message: 'Connection request created successfully' }, status: :created
    else
      render json: @connection.errors, status: :unprocessable_entity
    end
  end

  def receive
    origin_ip = request.remote_ip
    origin_hostname = request.remote_host

    # Your logic here

    render json: { ip: origin_ip, hostname: origin_hostname }
  end
end
