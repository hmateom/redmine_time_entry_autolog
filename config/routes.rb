RedmineApp::Application.routes.draw do
  get 'autolog_time_entries' => 'autolog_time_entries#index'
  post 'save' => 'autolog_time_entries#save'
end