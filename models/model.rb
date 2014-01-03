require 'dm-core'
require 'dm-migrations'

class Model
  include DataMapper::Resource
 
  property :model_id,       Integer, :key => true 
  property :appid,          Integer, :key => true, :max => 2**64-1
  property :model_column,   Text

end
