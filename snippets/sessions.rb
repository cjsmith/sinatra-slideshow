require 'sinatra'
require 'haml'

get '/login' { 
  haml :login 
}

post '/login' do
  if params[:name] = 'admin' and params[:password] = 'admin'
    session['user_name'] = params[:name]
  else
    redirect '/login'
  end
end

before do
  unless session['user_name']
    halt "Access denied, please <a href='/login'>login</a>."
  end
end

get '/' { 
  "Hello #{session['user_name']}." 
}

