
get '/recomms' do
  haml :recomms
end

get '/recomms_submit' do
  not_played,not_owned = @@cosine_recomms.get_recomms(params[:steamid])
  
  ids = not_played.map { |x| x['appid'] } .concat( not_owned.map { |x| x['appid'] } )

  @titles = {}
  games = Game.all(:fields => [:appid,:title], :appid => ids ) 
  games.each do |game|
    @titles[game.appid] = game.title
  end

  @recomms = not_played.zip( not_owned )
  haml :recomms_personal, :layout => :recomms_layout
end

get '/recomms/:steamid' do
  #scores = @@cosine_recomms.get_recomms('76561197971257137')
  scores = @@cosine_recomms.get_recomms(params[:steamid])
  # existing things are 0 and new things are 1
  @recomms = scores[0].zip( scores[1] )
  haml :recomms_personal, :layout => :recomms_layout
end



