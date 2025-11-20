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
end
