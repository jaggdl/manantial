module ApplicationHelper
  def active_link_to(name, path)
    if path == '/'
      class_name = request.path == '/' ? 'font-semibold' : ''
    else
      class_name = request.path.start_with?(path) ? 'font-semibold' : ''
    end
    link_to name, path, class: class_name
  end
end
