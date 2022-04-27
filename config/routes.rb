RedmineApp::Application.routes.draw do
  get 'autolog_time_entries' => 'autolog_time_entries#index'
  match '/autolog_time_entries/save', :to => 'autolog_time_entries#save', :via => [:post], :as => 'perform_autolog_time_entries'
end