require 'data_mapper'

if (@@config_obj)
  config_obj = @@config_obj
else
  config_obj = YAML::load_file( "#{File.expand_path('.')}/../config/steamrecommender.yml" )
end

host = config_obj['mysql_host']
db   = config_obj['mysql_db']
user = config_obj['mysql_user']
pass = config_obj['mysql_password']

DataMapper::Property::String.length(255)
DataMapper.setup(:default, "mysql://#{user}:#{pass}@#{host}/#{db}")

require_relative 'audit'
require_relative 'game'
require_relative 'game_duplicates'
require_relative 'genre'
require_relative 'genre_mapping'
require_relative 'model'

DataMapper.finalize
