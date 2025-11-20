class Quote < ApplicationRecord
  belongs_to :book

  enum status: {
    hidden: 0,
    pending: 1,
    published: 2
  }, _prefix: true
  # => quote.status_pending? / quote.status_published! みたいに使える

  validates :body, presence: true, length: { maximum: 200 }
  validates :page,
            numericality: { only_integer: true, allow_nil: true, greater_than: 0 }

  before_save :set_published_at_if_published

  private

  def set_published_at_if_published
    # status が published に変わるタイミングで、published_at が空なら現在時刻を入れる
    if will_save_change_to_status? && status_published? && published_at.nil?
      self.published_at = Time.current
    end
  end
end
