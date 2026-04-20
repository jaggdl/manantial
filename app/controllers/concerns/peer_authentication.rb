module PeerAuthentication
  extend ActiveSupport::Concern

  included do
    skip_before_action :require_authentication
    skip_before_action :verify_authenticity_token
    before_action :require_peer_authentication
  end

  private

  def require_peer_authentication
    token = extract_bearer_token

    if token.blank?
      return render json: { error: "Missing authorization token" }, status: :unauthorized
    end

    connection = Peers::Connection.active.find_by(access_key: token)

    unless connection
      return render json: { error: "Invalid or revoked access key" }, status: :unauthorized
    end

    Current.peer_connection = connection
  end

  def extract_bearer_token
    auth_header = request.headers["Authorization"]
    return nil if auth_header.blank?

    pattern = /^Bearer\s+/i
    auth_header.match?(pattern) ? auth_header.sub(pattern, "").strip : auth_header.strip
  end
end
