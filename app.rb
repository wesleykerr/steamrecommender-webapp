require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'yaml'
require 'haml'

require 'time.rb'
require 'recomms.rb'
config_obj = YAML::load_file( "#{File.expand_path('.')}/../config/steamrecommender.yml" )

use Rack::Session::Cookie, 
  :key => 'rack.session',
  :domain => 'steamrecommender.com',
  :path => '/',
  :expire_after => 86400,
  :secret => config_obj['secret_key']

configure do
  @@log = Logger.new(STDOUT)
  @@log.level = Logger::DEBUG
  
  @@config_obj = config_obj
  @@matrix_recomms = MatrixRecomms.new(@@config_obj)
end

get '/' do
  @title = 'Steam Recommender'
  haml :index
end

require 'helpers/helpers.rb'
require 'models/init.rb'
require 'routes/init.rb'

