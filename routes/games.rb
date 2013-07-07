

get '/games/:game' do
  @game = Game.get(params[:game])
  haml :games
end

get '/games/:game/edit' do
  @name = :game
  haml :edit_game
end

