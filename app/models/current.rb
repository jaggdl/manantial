class Current < ActiveSupport::CurrentAttributes
  attribute :session, :owner, :peer_connection
  delegate :user, to: :session, allow_nil: true
end
