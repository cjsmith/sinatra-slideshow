require 'your_sinatra_app'

YourRailsApp::Application.routes.draw do |map|

  match '/your_sinatra_app', :to => YourSinatraApp

end

