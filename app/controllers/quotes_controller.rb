class QuotesController < ApplicationController
  def new
    # BooksController から渡される ID を拾う
    book_id =
      if params[:selected_book_id].present?
        params[:selected_book_id]
      else
        params[:book_id]
      end

    @book = Book.find_by(id: book_id)

    if @book.nil?
      redirect_to search_books_path, alert: "先に書籍を選択してください"
      return
    end

    @quote = Quote.new(book: @book)
  end

  def create
    @quote = Quote.new(quote_params)

    if @quote.save
      redirect_to root_path, notice: "投稿が完了しました（承認までお待ちください）"
    else
      @book = @quote.book
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:book_id, :body, :page)
  end
end
