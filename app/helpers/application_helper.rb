module ApplicationHelper
  def error_messages_for_field(resource, field)
    return unless resource.errors[field].any?

    content_tag(:div, class: "field-errors") do
      resource.errors[field].map do |message|
        content_tag(:span, message, class: "error-message")
      end.join.html_safe
    end
  end
end
