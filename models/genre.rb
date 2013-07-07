
class Genre
  include DataMapper::Resource

  property :id,   Serial, :key => true
  property :name, String

  has n, :genre_mappings
  has n, :games, :through => :genre_mappings
end
