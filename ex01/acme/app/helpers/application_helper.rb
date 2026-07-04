module ApplicationHelper
  # Map Rails/Devise flash keys onto Bootstrap alert variants.
  def flash_bootstrap_class(type)
    {
      "notice" => "alert-success",
      "success" => "alert-success",
      "alert" => "alert-danger",
      "error" => "alert-danger",
      "warning" => "alert-warning"
    }.fetch(type.to_s, "alert-info")
  end

  # Bootstrap Icon paired with each flash variant.
  def flash_bootstrap_icon(type)
    {
      "notice" => "bi-check-circle-fill",
      "success" => "bi-check-circle-fill",
      "alert" => "bi-exclamation-octagon-fill",
      "error" => "bi-exclamation-octagon-fill",
      "warning" => "bi-exclamation-triangle-fill"
    }.fetch(type.to_s, "bi-info-circle-fill")
  end
end
