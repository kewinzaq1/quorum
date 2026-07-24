Rails.application.routes.draw do
  root "landing#index"

  resources :lunch_rooms, path: "rooms", param: :token, only: %i[new create show] do
    resources :participants, only: :create
    resources :research_runs, path: "research", only: %i[create show]
    resource :selection, only: :update
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
