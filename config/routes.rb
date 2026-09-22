Rails.application.routes.draw do
  get "/up", to: proc { [200, { "Content-Type" => "text/plain" }, ["ok"]] }

  post "/users", to: "users#create"
  post "/login", to: "users#login"
  get "/auto_login", to: "users#auto_login"

  resources :blogs do
    resources :comments, only: %i[index create update destroy], shallow: true
    resource :vote, only: %i[create destroy]
  end

  resources :tags, only: :index
end
