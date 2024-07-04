module ConnectionsHelper
  def connection_card_title(connection)
    if connection.public_info.present?
      return "#{connection.domain} · #{connection.public_info['name']}"
    end

    connection.domain
  end
end
