module ApplicationHelper
  def flash_class(level)
    case level.to_s
    when 'notice' then "alert alert-info"
    when 'success' then "alert alert-success"
    when 'error', 'alert' then "alert alert-danger"
    end
  end

  def flash_message(msg)
    if msg.is_a? String
      msg
    elsif msg.is_a? Array
      content_tag :ul do
        msg.map do |m|
          concat(content_tag :li, m)
        end
      end
    end
  end
end
