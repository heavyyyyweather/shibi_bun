# app/controllers/books_controller.rb

class BooksController < ApplicationController
  def new
    @book = Book.new(title: params[:title])
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to new_quote_path(book_search: @book.title, selected_book_id: @book.id),
                  notice: "書籍を登録しました。続けて一文を投稿できます。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create_by_isbn
    isbn = params[:isbn]&.delete("-")&.strip
    payload = OpenbdClient.fetch_by_isbn(isbn)

    if payload.present?
      book = Book.create_from_openbd_payload(payload, isbn)
      redirect_to new_quote_path(book_search: book.title, selected_book_id: book.id),
                  notice: "#{book.title} を登録・取得しました。続けて一文を投稿できます。"
    else
      redirect_to new_book_path, alert: "OpenBD から書誌情報が見つかりませんでした"
    end
  end

  def show
    @book = Book.find(params[:id])
    respond_to do |format|
      format.turbo_stream
    end
  end

  def search
    # ユーザー入力そのもの（ハイフン含む） → 表示や「手動登録」の初期値に使う
    @query = params[:q].to_s.strip
    @results = []

    normalized_isbn = normalize_isbn(@query)

    if normalized_isbn.present?
      book_data = BookLookupService.lookup(normalized_isbn)

      if book_data
        cover_url = book_data[:cover_url]

        @results << {
          source: book_data[:api_provider],
          data: {
            "summary" => {
              "title"     => book_data[:title],
              "author"    => book_data[:author],
              "publisher" => book_data[:publisher],
              "pubdate"   => book_data[:published_on],
              "isbn"      => book_data[:isbn13]
            }
          },
          cover_url: cover_url
        }
      end
    end
  end


  private

  # ISBN13 判定（13桁の数字のみ）
  def normalize_isbn(raw)
    digits = raw.to_s.gsub(/[^0-9Xx]/, "")

    case digits.length
    when 13
      return digits if digits.match?(/\A\d{13}\z/)
    when 10
      # 10桁（最後が数字 or X）なら 13桁に変換
      return IsbnConverter.to_isbn13(digits) if digits.match?(/\A\d{9}[\dXx]\z/)
    end

    nil
  end

  def book_params
    params.require(:book).permit(:title)
  end
end
