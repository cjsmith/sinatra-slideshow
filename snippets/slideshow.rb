require 'sinatra'
require 'uv'

get '/' do
  redirect '/slides/1'
end

get '/slides/:slide' do
  begin
    @slide = params[:slide].to_i
    @next_slide = @slide + 1
    @prev_slide = @slide - 1
    haml "slide#{@slide}".to_sym
  rescue Errno::ENOENT
    redirect '/slides/1'
  end
end

def load_snippet(snippet) 
  code = IO.read('snippets/' + snippet)
  Uv.parse( code, "xhtml", "ruby", false, "lazy")
end

