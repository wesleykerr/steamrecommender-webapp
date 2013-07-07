require 'data_mapper'

config_obj = YAML::load_file( "#{File.expand_path('models')}/../../config/steamrecommender.yml" )
host = config_obj['mysql_host']
db   = config_obj['mysql_db']
user = config_obj['mysql_user']
pass = config_obj['mysql_password']

DataMapper::Property::String.length(255)
DataMapper.setup(:default, "mysql://#{user}:#{pass}@#{host}/#{db}")

require 'models/game'
require 'models/genre'
require 'models/genre_mapping'

DataMapper.finalize
