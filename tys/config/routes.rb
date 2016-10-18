Rails.application.routes.draw do

  root to: "homepage#index"
  get "/search_results" => "homepage#search"

  # Users routes and applications routes
  resources :users, only: :show do
    get "applications/:id/show_public" => "applications#show_public", as: "application_show_public"
    resources :applications do
      resources :stack_traces
    end
  end

  resources :application, only: '' do
    resources :contributors, only: [:index, :destroy]
    resources :feedbacks, except: [:new,:show,:index]
    get "feedbacks/:parent_id/" => "feedbacks#new", as: "new_feedback"
    post "contributors/" => "contributors#composition_mail", as: "composition_mail_tm"
    post "contributors/all" => "contributors#composition_all", as: "composition_all_tm"
    post "send_mail" => "contributors#send_mail", as: "send_mail_tm"
    post "send_all" => "contributors#send_all", as: "send_all_tm"
    #post "response_feedback/create/:parent_id" => "feedbacks#create_response", as: "create_response_feedback"
  end

  get 'users_login' => 'users#login'
  get 'users_authorize' => 'users#authorize'
  get 'users_logout' => 'users#logout'

  get "stacktraces/:id/details" => "stacktraces#show_details"

end
