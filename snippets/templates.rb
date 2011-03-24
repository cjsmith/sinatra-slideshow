require 'haml'

get '/things' do
  @things = Things.all
  haml :index
  #will look for index.haml
end

#or

get '/things' do
  things = Things.all
  haml :index, :locals => { :things => things }
  #more typically used for faking partials
end

# can also use builder, erb, nokogiri, 
#   sass, scss, less, liquid, markdown,
#   textile, RDoc, etc in same fashion 

#mix and match
set :markdown, :layout_engine => :haml
