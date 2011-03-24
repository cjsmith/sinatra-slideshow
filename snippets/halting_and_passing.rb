#halting
get '/admin/console'
  halt(401) if session[:user].nil?

  #else render admin console
  #...
end

#passing
get '/guess/:who' do
  pass unless params[:who] == 'Frank'
  'You got me!'
end

get '/guess/*' do
  'You missed!'
end


