require Rails.root.join("lib/amazon_cover_helper")
module ApplicationHelper
  include AmazonCoverHelper
end
