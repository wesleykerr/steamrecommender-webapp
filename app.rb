require 'rubygems' # skip this line in ruby 1.9 and later
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'
require 'yaml'
require 'haml'

require 'time_ext.rb'
config_obj = YAML::load_file( "#{File.expand_path('.')}/../config/steamrecommender.yml" )

enable :sessions

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

