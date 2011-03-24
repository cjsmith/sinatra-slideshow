#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'haml'

set :port, 8080

## MODEL

class Poll
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :num_votes, Integer
  
  has n, :candidates

  def collect_votes
    repository.adapter.select(
        "SELECT c.id, count(v.id) AS num_votes, c.name
          FROM candidates c LEFT OUTER JOIN votes v ON c.id = v.candidate_id 
          WHERE c.poll_id = #{self.id}
          GROUP BY c.id
          ORDER BY num_votes desc"
    ).map{|row| [row.num_votes, row.name]}
  end
  
  def count_votes(ip)
    Vote.count(:ip => ip, Vote.candidate.poll.id => self.id)
  end

  def has_voted(ip)
    case self.num_votes
      when 0 then count_votes(ip) > 0
      else count_votes(ip) >= self.num_votes
    end
  end
end

class Candidate
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  has n, :votes
  belongs_to :poll
  
  def vote(ip)
    Vote.create(:ip => ip, :candidate => self) 
  end

end

class Vote 
  include DataMapper::Resource

  property :id, Serial
  property :ip, String

  belongs_to :candidate
  has 1, :poll, {:through => :candidate}
  
end

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/electioneering.db")
DataMapper.finalize

Poll.auto_upgrade!
Candidate.auto_upgrade!
Vote.auto_upgrade!

Presidential = Poll.first_or_create(:name => "US Presidential", :num_votes => 3)
Candidate.first_or_create(:poll => Presidential, :name => 'Obama')
Candidate.first_or_create(:poll => Presidential, :name => 'Palin')


# CONTROLLER

get '/' do
  redirect '/polls/' + Presidential.id.to_s 
end

get '/polls' do
  @polls = Poll.all
  haml :polls
end

get '/polls/new' do
  haml :new_poll 
end

post '/polls/create' do
  num_votes = case params[:vote_type]
          when 'checkbox' then 0 
          when 'single' then 1 
          when 'multi' then params[:num_votes] 
        end
  poll = Poll.create(:name => params[:name], :num_votes => num_votes)
  params[:candidates].each_line do |candidate_name|
    Candidate.create(:name => candidate_name.strip, :poll => poll)
  end
  redirect '/polls'
end

get '/polls/:poll_id' do
  @poll = Poll.get(params[:poll_id])
  @times_voted = @poll.count_votes(request.ip)
  redirect "/polls/#{@poll.id.to_s}/results" if @poll.has_voted(request.ip)
  @candidates = Candidate.all(:poll => @poll)
  if @poll.num_votes == 0
    haml :choose_many_candidates
  else
    haml :choose_one_candidate
  end
end	

post '/polls/:poll_id/vote' do
  @poll = Poll.get(params[:poll_id])
  @times_voted = @poll.count_votes(request.ip)
  redirect "/polls/#{@poll.id.to_s}/results" if @poll.has_voted(request.ip) 
  @poll.candidates.each do |candidate| 
    candidate_checked = !params['candidate-' + candidate.id.to_s].nil?
    candidate.vote(request.ip) if candidate_checked 
  end
  redirect '/polls/' + @poll.id.to_s + '/results'
end  

post '/polls/:poll_id/vote/:candidate_id' do
  @poll = Poll.get(params[:poll_id])
  candidate = Candidate.get(params[:candidate_id]) 
  candidate.vote(request.ip)
  redirect "/polls/#{@poll.id.to_s}"
end

get '/polls/:poll_id/results' do
  @poll = Poll.get(params[:poll_id])
  @votes = @poll.collect_votes 
  haml :results
end

__END__

## VIEW

@@ layout
%html
  = yield

@@ polls
%h3 Polls:
%ol 
  - @polls.each do |poll|
    %li
      %a{ :href => "/polls/#{poll.id}"} 
        =poll.name
%a{ :href => "polls/new" } New Poll    

@@new_poll
%h3 Create A New Poll:
%form{ :method => "post", :action => "/polls/create" }
  %label Name:
  %input{ :name => "name" }
  %br
  %br
  %label Vote Type:
  %br
  %input{ :name => "vote_type", :type => "radio", :value => "single" }
  %label Single Vote
  %br
  %input{ :name => "vote_type", :type => "radio", :value => "multi" }
  %label Multiple Votes
  %label (Limit 
  %input{ :name => "num_votes" , :size => 3}
  )
  %br
  %input{ :name => "vote_type", :type => "radio", :value => "checkbox" }
  %label Checkbox Vote
  %br
  %br
  %label List of Candidates (one per line):
  %br
  %textarea{ :name => "candidates", :rows => 5, :cols => 20 }
  %br
  %br
  %input{ :type => "submit" , :value => 'Create'}

@@ choose_many_candidates
%title #{@poll.name} Poll
%h3 #{@poll.name} Poll

%form{:method => "post", :action => "/polls/#{@poll.id}/vote"}
  %ol
    - @candidates.each do |candidate|
      %li
        =candidate.name 
        %input{:name => "candidate-#{candidate.id}", :type => "checkbox"}
  %input{:value => "vote", :type => "submit"}

@@ choose_one_candidate
%title #{@poll.name} Poll
%h3 #{@poll.name} Poll
%h2 Pick#{@times_voted > 0 && @times_voted < @poll.num_votes - 1 ? " Another":""} One#{@times_voted == @poll.num_votes - 1 ? " More":""}.
%ol
  - @candidates.each do |candidate|
    %li
      =candidate.name 
      %form{:method => "post", :action => "/polls/#{@poll.id}/vote/#{candidate.id}"}
        %input{:id => "#{candidate.name}", :value => "vote", :type => "submit"}

@@ results
%title #{@poll.name} Poll
%h3 #{@poll.name} Poll Results:
%table
  - @votes.each do |num_votes, candidate|
    %tr{:id => "#{candidate}"}
      %td{:align => 'right'} #{candidate}:
      %td #{num_votes == 1 ? "1 vote" : "#{num_votes} votes"}
