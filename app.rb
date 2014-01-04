require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'
require 'sinatra/json'
require 'yaml'
require 'haml'

require 'time_ext.rb'
config_obj = YAML::load_file( "#{File.expand_path('.')}/../config/steamrecommender.yml" )

configure do
  enable :sessions
  enable :logging
  @@config_obj = config_obj
end

before do
  env['rack.logger'] = Logger.new("logs/recommender.log", "weekly")
end

get '/' do
  @title = 'Steam Recommender'
  haml :index
end

require 'helpers/helpers.rb'
require 'models/init.rb'
require 'routes/init.rb'

