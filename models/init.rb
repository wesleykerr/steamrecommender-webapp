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

require 'models/audit'
require 'models/game'
require 'models/game_duplicates'
require 'models/genre'
require 'models/genre_mapping'
require 'models/model'

DataMapper.finalize
