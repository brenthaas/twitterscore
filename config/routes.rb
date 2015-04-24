Rails.application.routes.draw do
  get 'users/:handle/profile', to: 'users#profile'
  get 'users/:handle/recent_tweets', to: 'users#recent_tweets'
end
