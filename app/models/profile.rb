class Profile < ApplicationRecord
  require 'redcarpet/render_strip'

  extend Mobility
  translates :description, type: :text
  translates :info, type: :text

  mount_uploader :profile_picture, ProfilePictureUploader

  validate :only_one_profile, on: :create

  def info_to_html
    @info_markdown ||= Redcarpet::Markdown.new(
      MarkdownRendererWithSpecialLinks,
      autolink: true,
      space_after_headers: true,
      fenced_code_blocks: true
    )

    return nil if info.nil?

    @info_markdown.render(info).html_safe
  end

  def description_to_html
    @description_markdown ||= Redcarpet::Markdown.new(
      MarkdownRendererWithSpecialLinks,
      autolink: true,
      space_after_headers: true,
      fenced_code_blocks: true
    )

    return nil if description.nil?

    @description_markdown.render(description).html_safe
  end

  def plain_description
    @plain_description ||= Redcarpet::Markdown.new(Redcarpet::Render::StripDown)

    return nil if description.nil?

    @plain_description.render(description)
  end

  private

  def only_one_profile
    if Profile.exists?
      errors.add(:base, "There can be only one profile.")
    end
  end
end
