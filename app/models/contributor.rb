class Contributor < ApplicationRecord
  has_many :book_contributions, dependent: :destroy
  has_many :books, through: :book_contributions

  validates :name, presence: true
end
