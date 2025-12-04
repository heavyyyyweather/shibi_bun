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
      assign_book!

      save_quote!
    end

    if @quote.persisted?
      redirect_to root_path, notice: "投稿を受け付けました（承認待ちです）"
    else
      load_candidates_for(@book_search)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:body, :page, :book_id)
  end

  def assign_book!
    if @quote.book_id.present?
      @book = @quote.book
    elsif params[:google_isbn].present?
      @book = Book.fetch_or_create_by_isbn(params[:google_isbn])
      if @book.nil?
        @quote.errors.add(:base, "Google Books から書籍情報を取得できませんでした。")
        raise ActiveRecord::Rollback
      end
      @quote.book = @book
    else
      @quote.errors.add(:base, "本を選択してください")
      raise ActiveRecord::Rollback
    end
  end

  def save_quote!
    unless @quote.save
      raise ActiveRecord::Rollback
    end
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
