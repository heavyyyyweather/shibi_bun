require Rails.root.join("lib/amazon_cover_helper")
module ApplicationHelper
  include AmazonCoverHelper

  def hide_new_quote_button?
    controller_name.in?(%w[quotes books]) &&
      action_name.in?(%w[new create edit update search])
  end
end