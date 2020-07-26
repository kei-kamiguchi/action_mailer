Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.production?
  root 'contacts#new'
  resources :contacts
end
