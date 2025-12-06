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
    isbn = params[:isbn].to_s.strip
    book_data = BookLookupService.lookup(isbn)

    if book_data
      book = Book.find_or_initialize_by(isbn13: book_data[:isbn13])
      book.assign_attributes(book_data.slice(:title, :publisher, :published_on, :cover_url, :provider))
      book.save!
      redirect_to new_quote_path(book_search: book.title, selected_book_id: book.id),
                  notice: "#{book.title} を登録・取得しました。続けて一文を投稿できます。"
    else
      redirect_to new_book_path, alert: "書誌情報が見つかりませんでした"
    end
  end

  def show
    @book = Book.find(params[:id])
    respond_to do |format|
      format.turbo_stream
    end
  end

  def search
    @query = params[:q].to_s.strip
    @results = []

  if isbn13?(@query)
    result = OpenbdClient.fetch_by_isbn(@query)
    if result
      isbn13 = result.dig("summary", "isbn")
      cover_url = AmazonCoverHelper.url_for(isbn13)
      Rails.logger.debug("cover_url: #{cover_url}")

      @results << { source: "OpenBD", data: result, cover_url: cover_url }
    end
  end
end


  private

  # ISBN13 判定（13桁の数字のみ）
  def isbn13?(str)
    str.match?(/\A\d{13}\z/)
  end

  # 各APIの結果からISBN13を取り出す
  # def extract_isbn_from_result(result)
    # OpenBD形式
    # return result["summary"]["isbn"] if result.is_a?(Hash) && result.dig("summary", "isbn")

    # GoogleBooks形式
    # if result.is_a?(Hash) && result.dig("volumeInfo", "industryIdentifiers")
      # return result["volumeInfo"]["industryIdentifiers"]
                #.find { |id| id["type"] == "ISBN_13" }&.dig("identifier")
    # end

    # Rakuten形式
    # return result["isbn"] if result.is_a?(Hash) && result["isbn"]

    # nil
  # end

  def book_params
    params.require(:book).permit(:title)
  end
end
