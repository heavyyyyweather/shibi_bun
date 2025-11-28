# app/controllers/admin/book_imports_controller.rb
class Tools::BookImportsController < ApplicationController
  before_action :basic_auth! # いまのRailsAdminと同じBasicを使うイメージ

  def new
  end

  def create
    isbns = params[:isbns].to_s.lines.map(&:strip).reject(&:blank?)

    @results = isbns.map do |isbn|
      begin
        book = Book.create_from_google_books(isbn)

        if book
          { isbn:, status: :created, title: book.title }
        else
          { isbn:, status: :not_found }
        end
      rescue => e
        Rails.logger.error("[BookImports] #{isbn} error: #{e.class} #{e.message}")
        { isbn:, status: :error, error: e.message }
      end
    end

    render :new
  end
end
