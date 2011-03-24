require 'database_cleaner'
require 'rack/test'

RSpec.configure do |config|

  config.include Rack::Test::Methods

  config.before(:suite ) do
    DatabaseCleaner.strategy = :truncation, {:except => ['candidates','polls']}
  end

  config.before(:each ) do
    DatabaseCleaner.clean
  end

end

app_file = File.join(File.dirname(__FILE__), '..', 'electioneering.rb')
require app_file

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each {|f| require f}

