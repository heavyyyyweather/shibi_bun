class Tools::BookImportsController < ApplicationController
  before_action :basic_auth! # RailsAdmin と同様の Basic 認証

  def new
  end

  def create
    isbns = params[:isbns].to_s.lines.map(&:strip).reject(&:blank?)

    @results = isbns.map do |isbn|
      begin
        book = Book.fetch_or_create_by_isbn(isbn)

        if book
          { isbn: isbn, status: :created, title: book.title }
        else
          { isbn: isbn, status: :not_found }
        end
      rescue => e
        Rails.logger.error("[BookImports] #{isbn} error: #{e.class} #{e.message}")
        { isbn: isbn, status: :error, error: e.message }
      end
    end

    render :new
  end
end
