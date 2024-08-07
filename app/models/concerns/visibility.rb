module Visibility
  extend ActiveSupport::Concern

  included do
    attr_accessor :visibility

    before_save :set_visibility
    after_initialize :initialize_visibility

    scope :public_posts, -> { where(visible: true, private: false) }
    scope :visible_posts, -> { where(visible: true) }
  end

  def visibility_label
    if visible
      private ? 'connections' : 'public'
    else
      'hidden'
    end
  end

  def public?
    visible && !private
  end

  private

  def set_visibility
    case visibility
    when 'public'
      self.visible = true
      self.private = false
    when 'connections'
      self.visible = true
      self.private = true
    when 'hidden'
      self.visible = false
      self.private = false
    end
  end

  def initialize_visibility
    self.visibility = visibility_label
  end
end
