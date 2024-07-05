class Profile < ApplicationRecord
  mount_uploader :profile_picture, ProfilePictureUploader

  validate :only_one_profile, on: :create

  def info_to_html
    @info_markdown ||= Redcarpet::Markdown.new(
      MarkdownRendererWithSpecialLinks,
      autolink: true,
      space_after_headers: true,
      fenced_code_blocks: true
    )
    @info_markdown.render(info).html_safe
  end

  def description_to_html
    @description_markdown ||= Redcarpet::Markdown.new(
      MarkdownRendererWithSpecialLinks,
      autolink: true,
      space_after_headers: true,
      fenced_code_blocks: true
    )
    @description_markdown.render(description).html_safe
  end

  private

  def only_one_profile
    if Profile.exists?
      errors.add(:base, "There can be only one profile.")
    end
  end
end
