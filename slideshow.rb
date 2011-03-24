require 'sinatra'
require 'uv'

get '/' do
  redirect '/slides/0'
end

get '/slides/:slide' do
  begin
    @slide = params[:slide].to_i
    @next_slide = @slide + 1
    @prev_slide = @slide - 1
    haml "slide#{@slide}".to_sym
  rescue Errno::ENOENT
    p $!
    redirect '/slides/0'
  end
end

helpers do
  def load_snippet(snippet) 
    code = IO.read('snippets/' + snippet)
    Uv.parse( code, "xhtml", "ruby", false, "lazy")
  end
end

__END__

@@ layout

%html
  %head
    %title Slide #{@slide}
    %script{src:'/js/jquery.min.js'} 
    %script{src:'/js/jquery.hotkeys.js'}
    %link{href:'/css/slideshow.css', media:'all', rel:'stylesheet', type:'text/css'}
    %link{href:'/css/lazy.css', media:'all', rel:'stylesheet', type:'text/css'}
    :javascript
      $(document).ready(function(){
        $('#notes').hide();
        $('#show_info').toggle(
          function() {
            $('#content').hide('slow');
            $('#notes').show();
          }, function() {
            $('#notes').hide();
            $('#content').show('fast');
        });
       jQuery(document).bind('keypress', 'p', function(evt) {
          window.location = '/slides/#{@prev_slide}'; 
        });
        jQuery(document).bind('keypress', 'n', function(evt) {
          window.location = '/slides/#{@next_slide}'; 
        });
        jQuery(document).bind('keypress', 'i', function(evt) {
          $('#show_info').click(); 
        });
      });
  %body
    %h2 #{@slide}
    %a#show_info (i)nfo
    = yield
    - if (@prev_slide > 0)
      %a#nav_prev{href:"/slides/#{@prev_slide}"} (p)rev
    %a#nav_next{href:"/slides/#{@next_slide}"} (n)ext

@@ slide0 
#content
  %img{src:'/images/sinatra_life.jpg'}
#notes
  %h2 Spotlight on Sinatra

@@ slide1
#content
  %h2 Sinatra 
  %h3 The Little Web Framework That Can
  Colin Smith - Global Relay
#notes
  %h2 who i am
  %ul
    %li java developer who was introduced to RoR at a Ruby night hosted by a former company
    %li been using it for personal projects and the odd script at work ever since
    %li i now have to do morning affirmations to convince myself that programming java is still enjoyable
    %li i use sinatra a tool to quickly build out ideas from my idea journal

@@ slide2
#content
  %h2 Outline
  %ul
    %li What is Sinatra?
    %li Why I think it's great.
    %li What do you use Sinatra for?
#notes
  %ul 
    %li short and sweet intro; any longer would be misrepresenting Sinatra
    %li I'm a Java guy so I hope a room full of 40 Ruby guys will be able to teach me stuff as well as each other
    
@@slide3
#content
  %h2 Part 1: What is Sinatra?
  %ul 
    %li Written by Blake Miserany (Heroku) in 2007
    %li It's DSL for creating web applications in Ruby
    %li It's a web micro framework 
  ~load_snippet('hello_world.rb')  
#notes
  %ul
    %li hello world is 2-4 lines
    %li rails generates 43 files out of the box
    %li you can do an aweful lot in 100 lines
    %li lightning fast because it's just a thin layer over rack
    %li not necessarily model view controller but there's no reason it can't be. 
    %li so simple it will inspire you to create your own powerpoint
    %li I'm old.  Remember Perl CGI?  Remember J2EE? Wish you didn't? 

@@ slide4
#content
  %h2 RESTful Routes:
  ~load_snippet('routes.rb')
#notes
  %img{src:'/images/combo_taco_bell_pizza_hut.JPG'}
  %ul
    %li Routes are combined controller actions and routes together so you can see what's going on 
    %li They get searched in order upon a rack request and the first match going down wins

@@ slide5
#content
  %h2 Routes and Parameters:
  ~load_snippet('advanced_routes.rb')
#notes
  %ul
    %li params[:symbol] -> can be route symbols on gets or form fields on posts
    %li params[:splat] -> returns an array of wild card expressions

@@ slide6

#content
  %h2 Sessions and Stuff
  ~load_snippet('other_stuff.rb')
#notes
  %ul
    %li session[:symbol] -> stores stuff in a session
    %li goes down the list until it finds a match
    %li pass and halt

@@ slide7
#content
  %h2 Halting and Passing
  ~load_snippet('halting_and_passing.rb')
#notes
  %ul
    %li not used a whole bunch...

@@ slide8
#content
  %h2 Authentication
  %ul
    %li Basic Auth (use rack)
    %li sinatra-authentication
#notes
  To enforce security:
  %pre require 'rack-ssl-enforcer'
  %pre use Rack::SslEnforcer
  
@@ slide9
#content
  %h2 Templates
  ~load_snippet('templates.rb')
#notes  
  %ul 
    %li Tons of different template implementations
    %li you can pass variables or locals
    %li You can do partials in your templates by passing locals to them
    %li For more advanced partials you can google sinatra partials.rb
    %li You can use locals to pass/render markdown templates 

@@ slide10
#content
  %h2 Inline Templates
  ~load_snippet('../slideshow.rb')
#notes
  %ul
    %li non-trivial UI can get long (this slide show is ~200 lines but has 20 templates)
    %li no syntax highlighting :(

@@ slide11
#content
  %h2 Models
  You can easily integrate:
  %ul
    %li ActiveRecord(sinatra-activerecord)
    %li Sequel
    %li DataMapper
    %li Redis/CouchDB/NoSQL
    %li ???

@@ slide12
#content
  %h2 Eg. DataMapper
  ~load_snippet('electioneering.rb')
#notes
  %ul
    %li you can either store the model in a separate class or classes and require them or put them inline

@@ slide13
#content
  %h2. Deployment
  %ul
    %li capistrano
    %li heroku
#notes
 % 

@@ slide15
#content
  %h2 Minimalism
  %ul
    %li breeds clean design
    %li no boilerplate so you can execute your ideas right away
    %li makes it easier to focus on the problem

@@slideN
#content
  %Rails Interoperability

@@ slideN


@@slideN
#content
  %h2 Getting Startedf
  Fire up shotgun...
  

