class Current < ActiveSupport::CurrentAttributes
  attribute :session, :owner
  delegate :user, to: :session, allow_nil: true
end
