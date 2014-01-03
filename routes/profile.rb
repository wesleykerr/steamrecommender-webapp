

get '/profile/:steamid' do
  details = getProfile(params[:steamid])
  details.sort! { |x,y| y['playtime_forever'] <=> x['playtime_forever'] }
  json details
end


