require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'
require 'yaml'
require 'haml'

require 'time_ext.rb'
#require 'helpers/recomms.rb'
config_obj = YAML::load_file( "#{File.expand_path('.')}/../config/steamrecommender.yml" )

use Rack::Session::Cookie, 
  :key => 'rack.session',
  :domain => 'steamrecommender.com',
  :path => '/',
  :expire_after => 86400,
  :secret => config_obj['secret_key']

configure do
  @@config_obj = config_obj
end

get '/' do
  @title = 'Steam Recommender'
  haml :index
end

require 'helpers/helpers.rb'
require 'models/init.rb'
require 'routes/init.rb'

