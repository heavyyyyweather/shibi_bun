class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def basic_auth!
    authenticate_or_request_with_http_basic("Admin Area") do |username, password|
      username == ENV["ADMIN_USER"] && password == ENV["ADMIN_PASSWORD"]
    end
  end
end
