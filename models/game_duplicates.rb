require 'dm-core'
require 'dm-migrations'

class GameDuplicates
  include DataMapper::Resource

  property :correct_appid,     Integer, :min => 0, :max => 2**64-1, :key => true
  property :duplicate_appid,   Integer, :min => 0, :max => 2**64-1, :key => true
end

