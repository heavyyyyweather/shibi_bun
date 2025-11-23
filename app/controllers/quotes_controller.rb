class QuotesController < ApplicationController
  before_action :set_book_search, only: %i[new create]
  before_action :set_book_candidates, only: %i[new create]

  def new
    @quote = Quote.new

    # Quick Add から戻ってきたとき：
    # /quotes/new?book_search=...&selected_book_id=123
    if params[:selected_book_id].present?
      @quote.book_id = params[:selected_book_id].to_i
    end
  end

  def create
    @quote = Quote.new(quote_params)
    @quote.status ||= :pending  # ※モデル側デフォルトに寄せてもOK

    if @quote.save
      redirect_to root_path, notice: "投稿を受け付けました（承認待ちです）"
    else
      # バリデーションエラー時も、同じ検索状態を再現したい
      set_book_candidates
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:body, :page, :book_id)
  end

  def set_book_search
    @book_search = params[:book_search]
  end

  def set_book_candidates
    @book_candidates =
      if @book_search.present?
        Book.where("title ILIKE ?", "%#{@book_search}%").order(:title)
      else
        []
      end
  end
end
