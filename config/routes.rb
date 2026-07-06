Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :projects, only: %i[index show create destroy] do
    member do
      post :refresh
    end

    resource :deployment, only: :create
    resource :containers, only: :show, controller: "containers"
    resource :proxy, only: :show, controller: "proxy"
    resource :audit, only: :show, controller: "audits"
    resource :server_metrics, only: :show
  end

  resources :deployment_runs, only: :show

  root "projects#index"
end
