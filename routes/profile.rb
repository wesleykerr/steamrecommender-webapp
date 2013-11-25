

get '/profile' do
  unless session[:steamid]
    session[:returnTo] = '/profile'
    redirect to('/steamid')
  end
  json getProfile(session[:steamid])
end

get '/profile/:steamid' do
  details = get_game_details(params[:steamid])
  details['games'].sort! { |x,y| y['playtime_forever'] <=> x['playtime_forever'] }
  details.to_json
end

get '/prof' do
  results = getRecomms([400], 10)
  logger.info { "results: #{results}" }
  recomms = results.collect { |recomms| recomms.map { |app,score| app } }
  scores = results.collect { |recomms| recomms.map { |app,score| score } }
  "#{recomms.join("\t")}\n\n#{scores.join("\t")}"
end

