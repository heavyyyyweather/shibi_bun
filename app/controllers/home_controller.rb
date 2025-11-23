class HomeController < ApplicationController
  def index
    @quotes = Quote.published
                   .order(published_at: :desc)
                   .page(params[:page])
                   .per(10)
  end
end
