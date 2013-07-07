
class GenreMapping
  include DataMapper::Resource

  belongs_to :genre, :key => true
  belongs_to :game, :key => true
end
