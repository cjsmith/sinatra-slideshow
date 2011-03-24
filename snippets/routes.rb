get '/kittens/' do
  "Look at all the Kitties!"
end

get '/kittens/:id' do
  "Hello Kitty!"
end

post '/kittens' do
  "New Kitty!"
end

put '/kittens/:id' do
  "Update Kitty!"
end

delete '/kittens/:id' do
  "Goodbye Kitty.  Enjoy your new home."
end

