get '/stuff/:some_symbol' do
  #URL segments can be captured in params  
  some_resource = Stuff.find(params[:some_symbol])
end

post '/stuff/' do
  #form fields are retrieved by symbols
  some_resource = Stuff.create(:name=>params[:name])
end 

get '/download/*.*' do
  # wildcard matches /download/path/to/file.xml
  params[:splat] # => ["path/to/file", "xml"]
end

get %r{/hello/([\w]+)} do
  "Hello, #{params[:captures].first}!"
end

