module Peers
  class ProfileSerializer
    include ActiveModel::Serializers::JSON

    def initialize(user, view_context)
      @user = user
      @view_context = view_context
    end

    def attributes
      {
        "name" => nil,
        "avatar_url" => nil
      }
    end

    def name
      @user.name
    end

    def avatar_url
      @user.avatar.attached? ? @view_context.url_for(@user.avatar.variant(resize_to_limit: [128, 128])) : nil
    end
  end
end
