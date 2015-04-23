Rails.application.routes.draw do
  get 'users/:handle/profile', to: 'users#profile'
end
