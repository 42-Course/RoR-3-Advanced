module ApplicationHelper
  # Map Rails/Devise flash keys to our two visual flash styles.
  def flash_kind(type)
    case type.to_s
    when "alert", "error" then "alert"
    else "notice"
    end
  end
end
