
class Genre
  include DataMapper::Resource

  property :genre_id,   Integer, :key => true
  property :genre_name, String
end
