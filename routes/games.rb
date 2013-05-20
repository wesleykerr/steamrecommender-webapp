

get '/games/:game' do
  "requested /games/#{:game}"
  haml :games
end

get '/games/:game/edit' do
  @name = :game
  haml :edit_game
end

