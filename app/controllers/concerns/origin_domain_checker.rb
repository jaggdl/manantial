module OriginDomainChecker
  extend ActiveSupport::Concern

  included do
    before_action :check_origin_domain
  end

  private

  def check_origin_domain
    origin_domain = request.headers['X-Origin-Domain']
    request_ip = request.remote_ip

    if origin_domain.nil?
      return unauthorized_response('X-Origin-Domain header is missing')
    end

    begin
      resolved_ip = Resolv.getaddress(origin_domain)
    rescue Resolv::ResolvError
      return unauthorized_response('Domain could not be resolved')
    end

    unless Connection::Set.exists?(domain: origin_domain)
      return unauthorized_response('No connection found for the provided domain')
    end

    unless request_ip == resolved_ip
      return unauthorized_response('IP address mismatch')
    end
  end

  def unauthorized_response(message)
    render json: { error: 'Unauthorized', reason: message }, status: :unauthorized
  end
end
