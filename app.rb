require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'
require 'sinatra/json'
require 'yaml'

require_relative 'time_ext.rb'
config_obj = YAML::load_file( "#{File.expand_path('.')}/../config-app/steamrecommender.yml" )

configure do
  enable :sessions
  enable :logging
  @@config_obj = config_obj
end

before do
  env['rack.logger'] = Logger.new("log/recommender.log", "weekly")
end

get '/' do
  @title = 'Steam Recommender'
  haml :index
end

require_relative 'helpers/helpers.rb'
require_relative 'models/init.rb'
require_relative 'routes/init.rb'

