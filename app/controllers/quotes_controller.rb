class QuotesController < ApplicationController
  def new
    @book = Book.find_by(id: params[:selected_book_id])
    redirect_to search_books_path, alert: "書籍が見つかりませんでした" and return unless @book

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
