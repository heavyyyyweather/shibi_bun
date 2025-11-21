class QuotesController < ApplicationController
  before_action :set_book_candidates, only: %i[new create]

  def new
    # GET /quotes/new?book_search=...&quote[body]=... などから
    # すでに入力されている本文・ページを復元する
    @quote = Quote.new(quote_params_from_new)
  end

  def create
    @quote = Quote.new(quote_params)
    # DBデフォルトが pending でも、念のため明示
    @quote.status ||= :pending

    if @quote.save
      redirect_to root_path, notice: "投稿を受け付けました（承認待ちです）"
    else
      # ここで set_book_candidates がすでに呼ばれているので
      # 検索結果も保持された状態で new を再描画できる
      render :new, status: :unprocessable_entity
    end
  end

  private

  # POST /quotes で使う strong parameters
  def quote_params
    params.require(:quote).permit(:body, :page, :book_id)
  end

  # GET /quotes/new でも params[:quote] を受け取って
  # 本文やページを保持するためのゆるいパラメータ
  def quote_params_from_new
    params.fetch(:quote, {}).permit(:body, :page, :book_id)
  end

  # タイトル検索用の候補リストを new / create 両方で準備
  def set_book_candidates
    @book_search = params[:book_search]

    @book_candidates =
      if @book_search.present?
        Book.where("title ILIKE ?", "%#{@book_search}%").order(:title)
      else
        []
      end
  end
end
