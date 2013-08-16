require 'dm-core'
require 'dm-migrations'

class Game
  include DataMapper::Resource

  property :appid,            Integer, :min => 0, :max => 2**64-1, :key => true
  property :title,            String, :length => 256
  property :app_type,         String, :length => 50
  property :owned,            Integer
  property :not_played,       Integer
  property :total_playtime,   Decimal
  property :total_mean,       Decimal
  property :total_std,        Decimal
  property :recent_played,    Integer
  property :recent_playtime,  Decimal
  property :recent_mean,      Decimal
  property :recent_std,       Decimal

  property :metacritic,       String, :length => 256
  property :giantbomb_id,     Integer
  property :updated_datetime, DateTime

  property :steam_url,        String, :length => 256
  property :steam_img_url,    String, :length => 256
  property :last_checked,     DateTime

  has n, :genre_mappings
  has n, :genres, :through => :genre_mappings
end

