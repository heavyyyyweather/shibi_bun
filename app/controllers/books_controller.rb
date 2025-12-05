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
      ), notice: "書籍を登録しました。続けて一文を投稿できます。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create_by_isbn
    isbn = params[:isbn].to_s.strip

    if isbn.blank?
      redirect_to new_book_path, alert: "ISBNが入力されていません"
      return
    end

    book = Book.fetch_or_create_by_isbn(isbn)

    if book
      # 検索で得られた本をそのまま引用投稿に使う流れに
      redirect_to new_quote_path(
        book_search: book.title,
        selected_book_id: book.id
      ), notice: "#{book.title} を登録・取得しました。続けて一文を投稿できます。"
    else
      redirect_to new_book_path, alert: "書誌情報の取得に失敗しました"
    end
  end

  def show
    @book = Book.find(params[:id])

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def book_params
    # MVPのQuick Add段階では title のみに絞る
    params.require(:book).permit(:title)
  end
end
