class Tools::BookQuotesController < ApplicationController
  before_action :basic_auth!  # さっき ApplicationController に定義したやつ

  def new
    # 単にフォーム表示
  end

  def create
    isbn = params[:isbn].to_s
    body = params[:body].to_s
    page = params[:page].presence

    @errors = []

    @errors << "ISBNを入力してください" if isbn.blank?
    @errors << "引用本文を入力してください" if body.blank?

    if @errors.any?
      render :new and return
    end

    begin
      # Book を取得 or 作成
      @book  = Book.fetch_or_create_by_isbn(isbn)

      # Quote を1件作る（ステータスはお好みで）
      @quote = @book.quotes.create!(
        body: body,
        page: page,
        status: :published # default使いたければ外してOK
      )

      flash.now[:notice] = "登録しました"
    rescue => e
      @errors << "登録時にエラーが発生しました: #{e.message}"
    end

    render :new
  end
end
