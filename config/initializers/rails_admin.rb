RailsAdmin.config do |config|
  config.asset_source = :sprockets

  config.authenticate_with do
    authenticate_or_request_with_http_basic("Admin Area") do |username, password|
      username == ENV["ADMIN_USER"] && password == ENV["ADMIN_PASSWORD"]
    end
  end

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.main_app_name = [ "一文.COM", "Admin" ]

  config.model "Quote" do
    list do
      field :id
      field :body
      field :status
      field :book
      field :published_at
      field :created_at
    end

    edit do
      field :book
      field :body
      field :status
      field :published_at
      field :page
      field :admin_note
    end
  end

  config.model 'Book' do
    list do
      field :title
      field :isbn13
      field :api_provider
      field :api_synced_at
    end

    show do
      field :title
      field :isbn13
      field :publisher
      field :published_on
      field :cover_url
      field :api_provider
      field :api_synced_at
      field :api_payload do
        pretty_value do
          if value.present?
            "<pre style='white-space: pre-wrap; max-height: 300px; overflow-y: scroll;'>#{JSON.pretty_generate(value)}</pre>".html_safe
          end
        end
      end
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
