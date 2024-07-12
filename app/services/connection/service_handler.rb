module Connection
  class ServiceHandler
    def initialize(input)
      @input = input
    end

    def approve
      token = generate_token
      connection_service = Service.new(@input.domain)

      begin
        connection_service.set_connection(
          token: token,
          nonce: @input.nonce,
        )

        Connection::Set.create(
          token: token,
          domain: @input.domain,
        )

        @input.destroy
        { success: true, message: 'Connection was successfully approved.' }
      rescue Service::Error => e
        { success: false, message: "Error: #{e.message}" }
      rescue => e
        { success: false, message: "#{e.message}", raise_error: e }
      end
    end

    def create(message)
      @input.nonce = generate_token
      connection_service = Service.new(@input.domain)

      begin
        connection_service.request_connection(
          message: message,
          nonce: @input.nonce,
        )

        @input.save!
        { success: true, message: 'Out was successfully created.' }
      rescue Service::Error => e
        { success: false, message: "Error: #{e.message}" }
      rescue => e
        { success: false, message: "#{e.message}", raise_error: e }
      end
    end

    private

    def generate_token
      SecureRandom.hex(16)
    end
  end
end
