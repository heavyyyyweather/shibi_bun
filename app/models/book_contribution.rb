class BookContribution < ApplicationRecord
  belongs_to :book
  belongs_to :contributor

  # 役割: 著者・翻訳者・編者など
  enum role: {
    author: 0,
    translator: 1,
    editor: 2
  }, _prefix: true

  # position が nil でもOK（1著者,2著者...みたいに並べる時に使う想定）
end
