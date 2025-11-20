class Book < ApplicationRecord
  has_many :quotes, dependent: :destroy
  has_many :book_contributions, dependent: :destroy
  has_many :contributors, through: :book_contributions

  # enum: 0=google,1=openbd,2=manual（必要に応じて増やす）
  enum api_provider: {
    google: 0,
    openbd: 1,
    manual: 2
  }, _prefix: true

  validates :title, presence: true
  validates :isbn13, length: { is: 13 }, allow_blank: true
end
