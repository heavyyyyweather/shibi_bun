class QuotesController < ApplicationController
  def new
    @quote = Quote.new
    @book_search = params[:book_search].to_s.strip

    load_candidates_for(@book_search)
  end

  def create
    @book_search = params[:book_search].to_s.strip
    @quote       = Quote.new(quote_params)

    ActiveRecord::Base.transaction do
      # 1) 既存の Book を選んだ場合
      if @quote.book_id.present?
        @book = @quote.book

      # 2) Google Books の候補を選んだ場合
      elsif params[:google_isbn].present?
        @book = Book.fetch_or_create_by_isbn(params[:google_isbn])

        if @book.nil?
          @quote.errors.add(:base, "Google Books から書籍情報を取得できませんでした。")
          raise ActiveRecord::Rollback
        end

        @quote.book = @book

      # 3) どちらも選ばれてない
      else
        @quote.errors.add(:base, "本を選択してください")
        raise ActiveRecord::Rollback
      end

      # Quote 自体の保存
      unless @quote.save
        raise ActiveRecord::Rollback
      end
    end

    # ここまで来ていれば保存成功
    if @quote.persisted?
      redirect_to root_path, notice: "投稿を受け付けました（承認待ちです）"
    else
      # ロールバックされたときはこちら
      load_candidates_for(@book_search)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:body, :page, :book_id)
  end

  def load_candidates_for(keyword)
    if keyword.present?
      normalized_isbn = keyword.delete("-")

      @book_candidates = Book.where(
        "title ILIKE :q OR publisher ILIKE :q OR isbn13 LIKE :isbn",
        q: "%#{keyword}%",
        isbn: "%#{normalized_isbn}%"
      ).order(:title)

      @google_volumes = GoogleBooksClient.search(keyword, max_results: 5)
    else
      @book_candidates = []
      @google_volumes  = []
    end
  end
end
