#filters
before '/admin/*' do
  authenticate!
end


#sessions
enable :sessions

get '/session' do
  "value = " << session[:value].inspect
end

put '/session/:value' do
  session[:value] = params[:value]
end



