module Peers
  class PeerUser
    attr_reader :hostname, :name, :avatar_url

    def initialize(hostname:, name:, avatar_url:)
      @hostname = hostname
      @name = name
      @avatar_url = avatar_url
    end

    def display_name
      name.presence || hostname
    end
  end
end
