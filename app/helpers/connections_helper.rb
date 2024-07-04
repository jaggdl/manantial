module ConnectionsHelper
  def connection_card_title(connection)
    if connection.public_info.present?
      return "#{connection.public_info['name']} (#{connection.domain})"
    end

    connection.domain
  end
end
