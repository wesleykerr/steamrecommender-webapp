
get '/recomms' do
  haml :recomms
end

get '/recomms_submit' do
  not_played,not_owned = @@matrix_recomms.get_recomms(params[:steamid])
  ids = not_played.map { |x| x['appid'] } .concat( not_owned.map { |x| x['appid'] } )

  @games_map = {}
  games = Game.all(:fields => [:appid,:title,:steam_url,:steam_img_url], :appid => ids ) 
  games.each do |game|
    @games_map[game.appid] = game
  end

  @recomms = not_played.zip( not_owned )
  haml :recomms_personal
end

get '/recomms/:steamid' do
  not_played,not_owned = @@matrix_recomms.get_recomms(params[:steamid])
  ids = not_played.map { |x| x['appid'] } .concat( not_owned.map { |x| x['appid'] } )

  @games_map = {}
  games = Game.all(:fields => [:appid,:title,:steam_url,:steam_img_url], :appid => ids ) 
  games.each do |game|
    @games_map[game.appid] = game
  end

  @recomms = not_played.zip( not_owned )
  haml :recomms_personal
end



