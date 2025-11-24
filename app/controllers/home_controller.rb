# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @quotes = Quote.published
                   .order(published_at: :desc)
                   .includes(:book)
                   .page(params[:page])
                   .per(10)

    respond_to do |format|
      format.html  # 最初のページ読み込み
      format.turbo_stream  # 「さらに表示」クリック時
    end
  end
end
