Rails.application.routes.draw do
  root to: 'home#index'

  ## --- API namespacing
  namespace :api do
    namespace :v1 do
      resources :listings, only: [:index, :show] do
        member do
          get 'units'
        end
      end
      get 'ami' => 'listings#ami'
      get 'lottery-preferences' => 'listings#lottery_preferences'
      post 'listings-eligibility' => 'listings#eligibility'
    end
  end

  # required for Angular html5mode
  get '*path' => 'home#index'
end
