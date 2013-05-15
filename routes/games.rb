

get '/games/:game' do
  "requested /games/#{:game}"
  haml :games
end
