class BooksController < ApplicationController
  def new
    @book = Book.new(title: params[:title])
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      # 追加した本を選択済みの状態で /quotes/new に戻る
      redirect_to new_quote_path(
        book_search: @book.title,
        selected_book_id: @book.id
      )
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def book_params
    # MVPのQuick Add段階では title のみに絞る
    params.require(:book).permit(:title)
  end
end
