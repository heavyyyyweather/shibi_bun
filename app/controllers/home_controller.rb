class HomeController < ApplicationController
  def index
    @quotes = Quote.published
                   .order(Arel.sql("RANDOM()"))
                   .includes(:book)
                   .limit(20)
  end
end
