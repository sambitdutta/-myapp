require 'nokogiri'

module MessagesHelper
  def message_body(message)
    html = Nokogiri::HTML.parse(message.body)
    html.css('body').inner_html.html_safe
  end
end
